package com.erplist.replenishment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 预测评估指标（论文口径：MAE、RMSE、R²）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ForecastMetricsDTO {
    /** 样本点数量（用于计算指标的真实值点数） */
    private Integer n;
    private Double mae;
    private Double rmse;
    private Double r2;
}

