package com.erplist.replenishment.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 补货建议参数（可写入 application.yaml / nacos 配置，便于论文对齐与调参）
 */
@Data
@ConfigurationProperties(prefix = "replenishment.suggestion")
public class ReplenishmentSuggestionProperties {

    /**
     * 历史销量窗口天数（用于拉取订单时序）
     */
    private int historyDays = 30;

    /**
     * 预测未来天数（用于 LSTM 输出的 forecastTotal/forecastDaily）
     */
    private int forecastDays = 7;

    /**
     * 预测需求缓冲系数（用于应对波动，1.1 = 10% 加成）
     */
    private double forecastBufferRatio = 1.1;

    /**
     * 采购提前期（天），用于计算再订货点 ROP
     */
    private int leadTimeDays = 3;

    /**
     * 将库存表 minStock 作为安全库存（Safety Stock）
     */
    private boolean useMinStockAsSafetyStock = true;
}

