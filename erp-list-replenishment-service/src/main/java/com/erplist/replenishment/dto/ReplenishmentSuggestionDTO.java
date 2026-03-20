package com.erplist.replenishment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * LSTM 补货建议 DTO（单 SKU 一条）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReplenishmentSuggestionDTO {

    /** 店铺 ID（所属店铺） */
    private Long sid;
    /** SKU ID */
    private Long skuId;
    /** SKU 编码 */
    private String skuCode;
    /** 商品名称 */
    private String productName;
    /** 商品 ID */
    private Long productId;
    /** 预测周期内总需求量 */
    private Integer forecastTotal;
    /** 预测的每日需求量（按天） */
    private List<Double> forecastDaily;
    /** 当前库存（无记录时为 0） */
    private Integer currentStock;
    /** 安全库存（默认使用库存表 minStock；无记录时为 0） */
    private Integer safetyStock;
    /** 采购提前期（天） */
    private Integer leadTimeDays;
    /** 提前期需求量（= 日均需求 × 提前期） */
    private Integer leadTimeDemand;
    /** 再订货点 ROP（= 提前期需求量 + 安全库存） */
    private Integer reorderPoint;
    /** 建议补货数量（max(0, ROP - 当前库存)） */
    private Integer suggestedQuantity;
    /** 建议说明（便于前端展示与论文描述） */
    private String suggestionReason;
}
