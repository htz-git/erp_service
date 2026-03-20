package com.erplist.replenishment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 单 SKU 指标条目
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ForecastMetricsItemDTO {
    private Long skuId;
    private String skuCode;
    private String productName;
    private Long productId;
    private ForecastMetricsDTO metrics;
}

