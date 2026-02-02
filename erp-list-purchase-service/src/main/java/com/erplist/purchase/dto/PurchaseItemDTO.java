package com.erplist.purchase.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 采购明细 DTO
 */
@Data
public class PurchaseItemDTO {
    private Long id;
    private Long productId;

    @NotNull(message = "商品名称不能为空")
    private String productName;

    private Long skuId;
    private String skuCode;

    @NotNull(message = "采购单价不能为空")
    private BigDecimal purchasePrice;

    @NotNull(message = "采购数量不能为空")
    private Integer purchaseQuantity;

    private Integer arrivalQuantity;
    private BigDecimal totalPrice;
}
