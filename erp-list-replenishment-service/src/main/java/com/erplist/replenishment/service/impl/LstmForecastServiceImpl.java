package com.erplist.replenishment.service.impl;

import com.erplist.replenishment.service.LstmForecastService;
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
public class LstmForecastServiceImpl implements LstmForecastService {

    private static final int SEQ_LEN = 14;
    private static final int MIN_HISTORY_LEN = 5;
    private static final int MAX_FORECAST_DAYS = 30;
    private static final int LSTM_EPOCHS = 20;

    @Override
    public List<Map<String, Object>> predict(List<Map<String, Object>> series, int forecastDays) {
        int days = Math.max(1, Math.min(forecastDays, MAX_FORECAST_DAYS));
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
        if (values == null || values.size() < MIN_HISTORY_LEN) {
            double avg = values != null && !values.isEmpty()
                    ? values.stream().mapToDouble(Double::doubleValue).average().orElse(0) : 0;
            return repeat(Math.max(0, avg), forecastDays);
        }
        double[] arr = values.stream().mapToDouble(Double::doubleValue).toArray();
        int seqLen = Math.min(SEQ_LEN, arr.length - 1);
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
        org.deeplearning4j.nn.conf.MultiLayerConfiguration conf = buildLstmConfig(seqLen);
        org.deeplearning4j.nn.multilayer.MultiLayerNetwork net =
                new org.deeplearning4j.nn.multilayer.MultiLayerNetwork(conf);
        net.init();

        // 构造训练数据：滑动窗口 (X: seqLen 个点 -> y: 下一个点)
        int nSamples = values.length - seqLen;
        if (nSamples < 2) {
            return predictMovingAverage(values, forecastDays);
        }
        INDArray input = Nd4j.create(nSamples, 1, seqLen);
        INDArray labels = Nd4j.create(nSamples, 1);
        for (int i = 0; i < nSamples; i++) {
            for (int t = 0; t < seqLen; t++) {
                input.putScalar(i, 0, t, values[i + t]);
            }
            labels.putScalar(i, 0, values[i + seqLen]);
        }

        for (int epoch = 0; epoch < LSTM_EPOCHS; epoch++) {
            net.fit(input, labels);
        }

        // 自回归预测
        List<Double> forecast = new ArrayList<>();
        double[] lastSeq = Arrays.copyOfRange(values, values.length - seqLen, values.length);
        for (int d = 0; d < forecastDays; d++) {
            INDArray x = Nd4j.create(1, 1, seqLen);
            for (int t = 0; t < seqLen; t++) {
                x.putScalar(0, 0, t, lastSeq[t]);
            }
            INDArray out = net.output(x);
            double pred = Math.max(0, out.getDouble(0, 0));
            forecast.add(Math.round(pred * 100) / 100.0);
            // 滑动窗口：去掉第一个，末尾加上预测值
            double[] nextSeq = new double[seqLen];
            System.arraycopy(lastSeq, 1, nextSeq, 0, seqLen - 1);
            nextSeq[seqLen - 1] = pred;
            lastSeq = nextSeq;
        }
        return forecast;
    }

    private static org.deeplearning4j.nn.conf.MultiLayerConfiguration buildLstmConfig(int seqLen) {
        return new org.deeplearning4j.nn.conf.NeuralNetConfiguration.Builder()
                .seed(42)
                .updater(new org.nd4j.linalg.learning.config.Adam(0.01))
                .list()
                .layer(0, new org.deeplearning4j.nn.conf.layers.LSTM.Builder()
                        .nIn(1)
                        .nOut(32)
                        .activation(org.nd4j.linalg.activations.Activation.RELU)
                        .build())
                .layer(1, new org.deeplearning4j.nn.conf.layers.RnnOutputLayer.Builder(
                                new org.nd4j.linalg.lossfunctions.impl.LossMSE())
                        .nIn(32)
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
}
