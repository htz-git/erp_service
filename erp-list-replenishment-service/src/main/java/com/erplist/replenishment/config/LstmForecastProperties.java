package com.erplist.replenishment.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * LSTM 预测参数（与开题报告口径对齐，可配置）
 */
@Data
@ConfigurationProperties(prefix = "replenishment.lstm")
public class LstmForecastProperties {

    /**
     * 时间步长（例如 30 天）
     */
    private int timeSteps = 30;

    /**
     * 最小历史长度，过短则回退到移动平均
     */
    private int minHistoryLen = 5;

    /**
     * 最大预测天数
     */
    private int maxForecastDays = 30;

    /**
     * 隐藏单元数（例如 64）
     */
    private int hiddenUnits = 64;

    /**
     * 学习率（Adam）
     */
    private double learningRate = 0.001;

    /**
     * 最大训练轮次（例如 50）
     */
    private int epochs = 50;

    /**
     * 早停：连续 N 轮无提升则停止
     */
    private int earlyStopPatience = 5;

    /**
     * 早停：最小改善幅度
     */
    private double earlyStopMinDelta = 1e-4;

    /**
     * 是否启用 3σ（kσ）Winsorize 预处理（在 Min-Max 之前）
     */
    private boolean sigmaClipEnabled = true;

    /**
     * σ 倍数，默认 3 即 3σ 准则
     */
    private double sigmaMultiplier = 3.0;

    /**
     * 参与估计 μ、σ 的最少样本点数；不足则跳过该预处理
     */
    private int sigmaMinSamples = 8;
}

