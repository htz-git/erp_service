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
    /** 建议补货数量（与 forecastTotal 一致，或可根据当前库存再减） */
    private Integer suggestedQuantity;
}
