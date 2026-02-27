package com.erplist.purchase.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 补货建议单项（与 ReplenishmentSuggestionDTO 对齐，用于生成采购单）
 */
@Data
public class SuggestionItemDTO {
    private Long sid;
    @NotNull(message = "商品ID不能为空")
    private Long productId;
    private String productName;
    private Long skuId;
    private String skuCode;
    @NotNull(message = "建议补货量不能为空")
    private Integer suggestedQuantity;
}
