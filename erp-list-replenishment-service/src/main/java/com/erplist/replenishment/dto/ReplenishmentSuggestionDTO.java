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
    /** 建议补货数量（max(0, 预测需求量 - 当前库存)） */
    private Integer suggestedQuantity;
}
