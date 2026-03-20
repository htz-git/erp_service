package com.erplist.replenishment.service.impl;

import com.erplist.replenishment.config.LstmForecastProperties;
import com.erplist.replenishment.dto.ForecastMetricsDTO;
import com.erplist.replenishment.dto.ForecastMetricsItemDTO;
import com.erplist.replenishment.dto.ForecastMetricsResultDTO;
import com.erplist.replenishment.service.LstmForecastService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.factory.Nd4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * LSTM + 自回归预测实现：优先使用 DL4J，数据不足或异常时退回移动平均
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LstmForecastServiceImpl implements LstmForecastService {

    private final LstmForecastProperties props;

    @Override
    public List<Map<String, Object>> predict(List<Map<String, Object>> series, int forecastDays) {
        int days = Math.max(1, Math.min(forecastDays, props.getMaxForecastDays()));
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> item : series) {
            @SuppressWarnings("unchecked")
            List<Number> rawValues = (List<Number>) item.get("values");
            List<Double> values = rawValues == null ? Collections.emptyList()
                    : rawValues.stream().map(Number::doubleValue).collect(Collectors.toList());
            List<Double> forecastDaily = predictOne(values, days);
            double sumDaily = forecastDaily.stream().mapToDouble(Double::doubleValue).sum();
            int forecastTotal = (int) Math.round(sumDaily);
            Map<String, Object> out = new HashMap<>(item);
            out.remove("values");
            out.put("forecastTotal", forecastTotal);
            out.put("forecastDaily", forecastDaily);
            result.add(out);
        }
        return result;
    }

    private List<Double> predictOne(List<Double> values, int forecastDays) {
        if (values == null || values.size() < props.getMinHistoryLen()) {
            double avg = values != null && !values.isEmpty()
                    ? values.stream().mapToDouble(Double::doubleValue).average().orElse(0) : 0;
            return repeat(Math.max(0, avg), forecastDays);
        }
        double[] arr = values.stream().mapToDouble(Double::doubleValue).toArray();
        int seqLen = Math.min(props.getTimeSteps(), arr.length - 1);
        if (seqLen < 2) {
            double avg = Arrays.stream(arr).average().orElse(0);
            return repeat(Math.max(0, avg), forecastDays);
        }
        try {
            return predictWithLstm(arr, seqLen, forecastDays);
        } catch (Throwable t) {
            log.debug("LSTM 预测失败，使用移动平均: {}", t.getMessage());
            return predictMovingAverage(arr, forecastDays);
        }
    }

    private List<Double> predictWithLstm(double[] values, int seqLen, int forecastDays) {
        org.deeplearning4j.nn.conf.MultiLayerConfiguration conf = buildLstmConfig();
        org.deeplearning4j.nn.multilayer.MultiLayerNetwork net =
                new org.deeplearning4j.nn.multilayer.MultiLayerNetwork(conf);
        net.init();

        // 归一化到 [0,1]，与开题报告口径对齐；预测后再反归一化
        MinMaxScaler scaler = MinMaxScaler.fit(values);
        double[] scaled = scaler.transform(values);

        // 构造训练数据：滑动窗口 (X: seqLen 个点 -> 每个时间步预测下一时刻，labels 与 input 同长)
        // DL4J RnnOutputLayer 要求 labels 的 sequence length 与 input 一致，即 [batch, nOut, seqLen]
        int nSamples = scaled.length - seqLen;
        if (nSamples < 2) {
            return predictMovingAverage(values, forecastDays);
        }
        INDArray input = Nd4j.create(nSamples, 1, seqLen);
        INDArray labels = Nd4j.create(nSamples, 1, seqLen);
        for (int i = 0; i < nSamples; i++) {
            for (int t = 0; t < seqLen; t++) {
                input.putScalar(i, 0, t, scaled[i + t]);
                // 时间步 t 的标签 = 下一时刻的值 scaled[i+t+1]，最后一格 t=seqLen-1 即为 scaled[i+seqLen]
                labels.putScalar(i, 0, t, scaled[i + t + 1]);
            }
        }

        // 早停：使用最后 20% 的样本窗口作为验证集
        int totalSamples = (int) input.size(0);
        int valSamples = Math.max(1, (int) Math.round(totalSamples * 0.2));
        int trainSamples = Math.max(1, totalSamples - valSamples);
        INDArray trainX = input.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(0, trainSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());
        INDArray trainY = labels.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(0, trainSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());
        INDArray valX = input.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(trainSamples, totalSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());
        INDArray valY = labels.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(trainSamples, totalSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());

        double bestVal = Double.POSITIVE_INFINITY;
        int noImprove = 0;
        for (int epoch = 0; epoch < props.getEpochs(); epoch++) {
            net.fit(trainX, trainY);
            double valLoss = mseOn(valX, valY, net);
            if (bestVal - valLoss > props.getEarlyStopMinDelta()) {
                bestVal = valLoss;
                noImprove = 0;
            } else {
                noImprove++;
                if (noImprove >= props.getEarlyStopPatience()) {
                    break;
                }
            }
        }

        // 自回归预测
        List<Double> forecast = new ArrayList<>();
        double[] lastSeq = Arrays.copyOfRange(scaled, scaled.length - seqLen, scaled.length);
        for (int d = 0; d < forecastDays; d++) {
            INDArray x = Nd4j.create(1, 1, seqLen);
            for (int t = 0; t < seqLen; t++) {
                x.putScalar(0, 0, t, lastSeq[t]);
            }
            INDArray out = net.output(x);
            // 输出形状 [1, 1, seqLen]，取最后一个时间步作为“下一日”预测
            double predScaled = clamp01(out.getDouble(0, 0, seqLen - 1));
            double pred = Math.max(0, scaler.inverse(predScaled));
            forecast.add(Math.round(pred * 100) / 100.0);
            // 滑动窗口：去掉第一个，末尾加上预测值
            double[] nextSeq = new double[seqLen];
            System.arraycopy(lastSeq, 1, nextSeq, 0, seqLen - 1);
            nextSeq[seqLen - 1] = predScaled;
            lastSeq = nextSeq;
        }
        return forecast;
    }

    private org.deeplearning4j.nn.conf.MultiLayerConfiguration buildLstmConfig() {
        return new org.deeplearning4j.nn.conf.NeuralNetConfiguration.Builder()
                .seed(42)
                .updater(new org.nd4j.linalg.learning.config.Adam(props.getLearningRate()))
                .list()
                .layer(0, new org.deeplearning4j.nn.conf.layers.LSTM.Builder()
                        .nIn(1)
                        .nOut(props.getHiddenUnits())
                        .activation(org.nd4j.linalg.activations.Activation.TANH)
                        .build())
                .layer(1, new org.deeplearning4j.nn.conf.layers.RnnOutputLayer.Builder(
                                new org.nd4j.linalg.lossfunctions.impl.LossMSE())
                        .nIn(props.getHiddenUnits())
                        .nOut(1)
                        .activation(org.nd4j.linalg.activations.Activation.IDENTITY)
                        .build())
                .build();
    }

    private static List<Double> predictMovingAverage(double[] values, int forecastDays) {
        int window = Math.min(14, values.length);
        double sum = 0;
        for (int i = values.length - window; i < values.length; i++) {
            sum += values[i];
        }
        double avg = sum / window;
        return repeat(Math.max(0, avg), forecastDays);
    }

    private static List<Double> repeat(double value, int n) {
        List<Double> list = new ArrayList<>(n);
        for (int i = 0; i < n; i++) {
            list.add(value);
        }
        return list;
    }

    @Override
    public ForecastMetricsResultDTO evaluate(List<Map<String, Object>> series) {
        if (series == null || series.isEmpty()) {
            return ForecastMetricsResultDTO.builder()
                    .overall(ForecastMetricsDTO.builder().n(0).mae(null).rmse(null).r2(null).build())
                    .perSku(Collections.emptyList())
                    .build();
        }

        List<ForecastMetricsItemDTO> perSku = new ArrayList<>();
        List<Double> allY = new ArrayList<>();
        List<Double> allYhat = new ArrayList<>();

        for (Map<String, Object> item : series) {
            Long skuId = longFrom(item.get("skuId"));
            String skuCode = stringOf(item.get("skuCode"));
            String productName = stringOf(item.get("productName"));
            Long productId = longFrom(item.get("productId"));
            @SuppressWarnings("unchecked")
            List<Number> rawValues = (List<Number>) item.get("values");
            List<Double> values = rawValues == null ? Collections.emptyList()
                    : rawValues.stream().map(Number::doubleValue).collect(Collectors.toList());

            EvalPair pair = evaluateOne(values);
            if (pair.metrics.getN() != null && pair.metrics.getN() > 0) {
                allY.addAll(pair.y);
                allYhat.addAll(pair.yhat);
            }
            perSku.add(ForecastMetricsItemDTO.builder()
                    .skuId(skuId)
                    .skuCode(skuCode)
                    .productName(productName)
                    .productId(productId)
                    .metrics(pair.metrics)
                    .build());
        }

        ForecastMetricsDTO overall = computeMetrics(allY, allYhat);
        return ForecastMetricsResultDTO.builder().overall(overall).perSku(perSku).build();
    }

    private EvalPair evaluateOne(List<Double> values) {
        if (values == null || values.size() < Math.max(props.getMinHistoryLen(), 5)) {
            return new EvalPair(Collections.emptyList(), Collections.emptyList(),
                    ForecastMetricsDTO.builder().n(0).mae(null).rmse(null).r2(null).build());
        }
        double[] arr = values.stream().mapToDouble(Double::doubleValue).toArray();
        int totalLen = arr.length;
        int trainLen = Math.max(2, (int) Math.floor(totalLen * 0.7));
        int testLen = totalLen - trainLen;
        if (testLen < 2) {
            return new EvalPair(Collections.emptyList(), Collections.emptyList(),
                    ForecastMetricsDTO.builder().n(0).mae(null).rmse(null).r2(null).build());
        }

        int seqLen = Math.min(props.getTimeSteps(), trainLen - 1);
        if (seqLen < 2) {
            // 序列太短：移动平均评估
            List<Double> y = new ArrayList<>();
            List<Double> yhat = new ArrayList<>();
            for (int i = trainLen; i < totalLen; i++) {
                y.add(arr[i]);
                yhat.add(movingAvg(arr, Math.max(0, i - 14), i));
            }
            return new EvalPair(y, yhat, computeMetrics(y, yhat));
        }

        try {
            // 训练：仅用 train 部分拟合
            double[] trainValues = Arrays.copyOfRange(arr, 0, trainLen);
            org.deeplearning4j.nn.multilayer.MultiLayerNetwork net = fitModel(trainValues, seqLen);

            // walk-forward：对 test 部分逐点预测（单步预测）
            MinMaxScaler scaler = MinMaxScaler.fit(trainValues);
            double[] scaledAll = scaler.transform(Arrays.copyOfRange(arr, 0, totalLen));

            List<Double> y = new ArrayList<>();
            List<Double> yhat = new ArrayList<>();
            for (int i = trainLen; i < totalLen; i++) {
                if (i - seqLen < 0) continue;
                INDArray x = Nd4j.create(1, 1, seqLen);
                for (int t = 0; t < seqLen; t++) {
                    x.putScalar(0, 0, t, scaledAll[i - seqLen + t]);
                }
                INDArray out = net.output(x);
                double predScaled = clamp01(out.getDouble(0, 0, seqLen - 1));
                double pred = Math.max(0, scaler.inverse(predScaled));
                y.add(arr[i]);
                yhat.add(pred);
            }
            return new EvalPair(y, yhat, computeMetrics(y, yhat));
        } catch (Throwable t) {
            log.debug("LSTM 指标评估失败，使用移动平均: {}", t.getMessage());
            List<Double> y = new ArrayList<>();
            List<Double> yhat = new ArrayList<>();
            for (int i = trainLen; i < totalLen; i++) {
                y.add(arr[i]);
                yhat.add(movingAvg(arr, Math.max(0, i - 14), i));
            }
            return new EvalPair(y, yhat, computeMetrics(y, yhat));
        }
    }

    private org.deeplearning4j.nn.multilayer.MultiLayerNetwork fitModel(double[] values, int seqLen) {
        MinMaxScaler scaler = MinMaxScaler.fit(values);
        double[] scaled = scaler.transform(values);
        int nSamples = scaled.length - seqLen;
        INDArray input = Nd4j.create(nSamples, 1, seqLen);
        INDArray labels = Nd4j.create(nSamples, 1, seqLen);
        for (int i = 0; i < nSamples; i++) {
            for (int t = 0; t < seqLen; t++) {
                input.putScalar(i, 0, t, scaled[i + t]);
                labels.putScalar(i, 0, t, scaled[i + t + 1]);
            }
        }

        org.deeplearning4j.nn.multilayer.MultiLayerNetwork net =
                new org.deeplearning4j.nn.multilayer.MultiLayerNetwork(buildLstmConfig());
        net.init();

        int totalSamples = (int) input.size(0);
        if (totalSamples < 2) {
            return net;
        }
        int valSamples = Math.max(1, (int) Math.round(totalSamples * 0.2));
        int trainSamples = Math.max(1, totalSamples - valSamples);
        INDArray trainX = input.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(0, trainSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());
        INDArray trainY = labels.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(0, trainSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());
        INDArray valX = input.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(trainSamples, totalSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());
        INDArray valY = labels.get(org.nd4j.linalg.indexing.NDArrayIndex.interval(trainSamples, totalSamples),
                org.nd4j.linalg.indexing.NDArrayIndex.all(),
                org.nd4j.linalg.indexing.NDArrayIndex.all());

        double bestVal = Double.POSITIVE_INFINITY;
        int noImprove = 0;
        for (int epoch = 0; epoch < props.getEpochs(); epoch++) {
            net.fit(trainX, trainY);
            double valLoss = mseOn(valX, valY, net);
            if (bestVal - valLoss > props.getEarlyStopMinDelta()) {
                bestVal = valLoss;
                noImprove = 0;
            } else {
                noImprove++;
                if (noImprove >= props.getEarlyStopPatience()) {
                    break;
                }
            }
        }
        return net;
    }

    private static double mseOn(INDArray x, INDArray y, org.deeplearning4j.nn.multilayer.MultiLayerNetwork net) {
        if (x == null || y == null || x.isEmpty() || y.isEmpty()) return Double.POSITIVE_INFINITY;
        INDArray out = net.output(x);
        INDArray diff = out.sub(y);
        INDArray sq = diff.mul(diff);
        return sq.meanNumber().doubleValue();
    }

    private static ForecastMetricsDTO computeMetrics(List<Double> y, List<Double> yhat) {
        int n = Math.min(y == null ? 0 : y.size(), yhat == null ? 0 : yhat.size());
        if (n <= 0) {
            return ForecastMetricsDTO.builder().n(0).mae(null).rmse(null).r2(null).build();
        }

        double sumAbs = 0;
        double sumSq = 0;
        double meanY = 0;
        for (int i = 0; i < n; i++) meanY += y.get(i);
        meanY /= n;

        double sst = 0;
        double sse = 0;
        for (int i = 0; i < n; i++) {
            double yi = y.get(i);
            double yhi = yhat.get(i);
            double err = yi - yhi;
            sumAbs += Math.abs(err);
            sumSq += err * err;
            double dy = yi - meanY;
            sst += dy * dy;
            sse += err * err;
        }
        double mae = sumAbs / n;
        double rmse = Math.sqrt(sumSq / n);
        Double r2 = sst > 0 ? 1.0 - (sse / sst) : null;

        return ForecastMetricsDTO.builder()
                .n(n)
                .mae(round4(mae))
                .rmse(round4(rmse))
                .r2(r2 == null ? null : round4(r2))
                .build();
    }

    private static double round4(double v) {
        return Math.round(v * 10000d) / 10000d;
    }

    private static double movingAvg(double[] arr, int fromInclusive, int toExclusive) {
        int from = Math.max(0, fromInclusive);
        int to = Math.min(arr.length, toExclusive);
        if (to <= from) return 0;
        double sum = 0;
        for (int i = from; i < to; i++) sum += arr[i];
        return sum / (to - from);
    }

    private static double clamp01(double v) {
        if (Double.isNaN(v) || Double.isInfinite(v)) return 0;
        if (v < 0) return 0;
        if (v > 1) return 1;
        return v;
    }

    private static Long longFrom(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).longValue();
        try {
            return Long.parseLong(o.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String stringOf(Object o) {
        return o != null ? o.toString() : "";
    }

    private static final class EvalPair {
        private final List<Double> y;
        private final List<Double> yhat;
        private final ForecastMetricsDTO metrics;

        private EvalPair(List<Double> y, List<Double> yhat, ForecastMetricsDTO metrics) {
            this.y = y;
            this.yhat = yhat;
            this.metrics = metrics;
        }
    }

    private static final class MinMaxScaler {
        private final double min;
        private final double max;

        private MinMaxScaler(double min, double max) {
            this.min = min;
            this.max = max;
        }

        static MinMaxScaler fit(double[] values) {
            double min = Double.POSITIVE_INFINITY;
            double max = Double.NEGATIVE_INFINITY;
            for (double v : values) {
                if (Double.isNaN(v) || Double.isInfinite(v)) continue;
                if (v < min) min = v;
                if (v > max) max = v;
            }
            if (!Double.isFinite(min) || !Double.isFinite(max)) {
                min = 0;
                max = 1;
            }
            return new MinMaxScaler(min, max);
        }

        double[] transform(double[] values) {
            double[] out = new double[values.length];
            double range = max - min;
            if (range <= 1e-12) {
                Arrays.fill(out, 0.0);
                return out;
            }
            for (int i = 0; i < values.length; i++) {
                double v = values[i];
                if (!Double.isFinite(v)) v = min;
                out[i] = clamp01((v - min) / range);
            }
            return out;
        }

        double inverse(double scaled) {
            double range = max - min;
            if (range <= 1e-12) return min;
            return min + clamp01(scaled) * range;
        }
    }
}
