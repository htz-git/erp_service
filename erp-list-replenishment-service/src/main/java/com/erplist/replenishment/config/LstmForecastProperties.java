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
}

