package com.erplist.replenishment.support;

import java.util.Arrays;

/**
 * 基于均值与标准差的 Winsorize（缩尾）：将超出 [mean − k·σ, mean + k·σ] 的点压回边界，
 * 用于抑制极端销量对 LSTM 与 Min-Max 的影响。销量非负，截断后保证 ≥ 0。
 */
public final class SigmaWinsorizer {

    private static final double STD_EPS = 1e-9;

    private SigmaWinsorizer() {}

    /**
     * 用整段序列估计 μ、σ，再对整段做 Winsorize（用于在线预测）。
     */
    public static double[] winsorizeFullSeries(double[] raw, boolean enabled, double sigmaMultiplier,
            int minSamples) {
        if (!enabled || raw == null || raw.length == 0) {
            return raw == null ? new double[0] : raw.clone();
        }
        if (raw.length < minSamples) {
            return raw.clone();
        }
        Stats st = statsOfFiniteValues(raw);
        if (st == null || st.std <= STD_EPS) {
            return raw.clone();
        }
        return winsorizeWithBounds(raw, st.mean, st.std, sigmaMultiplier);
    }

    /**
     * 仅用 [0, trainEndExclusive) 子段估计 μ、σ，再对整条序列做 Winsorize（用于评估集，避免用测试段统计量）。
     */
    public static double[] winsorizeUsingTrainHead(double[] full, int trainEndExclusive, boolean enabled,
            double sigmaMultiplier, int minSamples) {
        if (!enabled || full == null || full.length == 0) {
            return full == null ? new double[0] : full.clone();
        }
        if (trainEndExclusive < minSamples || trainEndExclusive > full.length) {
            return full.clone();
        }
        double[] train = Arrays.copyOfRange(full, 0, trainEndExclusive);
        Stats st = statsOfFiniteValues(train);
        if (st == null || st.std <= STD_EPS) {
            return full.clone();
        }
        return winsorizeWithBounds(full, st.mean, st.std, sigmaMultiplier);
    }

    private static double[] winsorizeWithBounds(double[] raw, double mean, double std, double k) {
        double lo = mean - k * std;
        double hi = mean + k * std;
        double[] out = new double[raw.length];
        for (int i = 0; i < raw.length; i++) {
            double v = raw[i];
            if (!Double.isFinite(v)) {
                v = mean;
            }
            if (v < lo) {
                v = lo;
            } else if (v > hi) {
                v = hi;
            }
            if (v < 0) {
                v = 0;
            }
            out[i] = v;
        }
        return out;
    }

    /** 有限样本标准差（n≥2 时用 n−1 分母） */
    private static Stats statsOfFiniteValues(double[] values) {
        double sum = 0;
        int n = 0;
        for (double v : values) {
            if (Double.isFinite(v)) {
                sum += v;
                n++;
            }
        }
        if (n < 2) {
            return null;
        }
        double mean = sum / n;
        double sq = 0;
        for (double v : values) {
            if (Double.isFinite(v)) {
                double d = v - mean;
                sq += d * d;
            }
        }
        double std = Math.sqrt(sq / (n - 1));
        return new Stats(mean, std);
    }

    private static final class Stats {
        private final double mean;
        private final double std;

        private Stats(double mean, double std) {
            this.mean = mean;
            this.std = std;
        }
    }
}
