package com.erplist.replenishment.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * LSTM 预测服务配置（Python 服务地址等）
 */
@Data
@Component
@ConfigurationProperties(prefix = "lstm.forecast")
public class LstmForecastProperties {

    /** LSTM 预测服务根 URL，如 http://localhost:5000 */
    private String serviceUrl = "http://localhost:5000";
    /** 连接超时（毫秒） */
    private int connectTimeout = 5000;
    /** 读取超时（毫秒） */
    private int readTimeout = 30000;
}
