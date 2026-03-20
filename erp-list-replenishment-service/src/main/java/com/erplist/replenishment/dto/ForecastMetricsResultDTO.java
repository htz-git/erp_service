package com.erplist.replenishment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 指标汇总：overall + perSku
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ForecastMetricsResultDTO {
    private ForecastMetricsDTO overall;
    private List<ForecastMetricsItemDTO> perSku;
}

