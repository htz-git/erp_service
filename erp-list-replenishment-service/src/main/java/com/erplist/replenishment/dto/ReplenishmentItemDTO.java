package com.erplist.replenishment.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 补货明细 DTO
 */
@Data
public class ReplenishmentItemDTO {
    private Long id;
    private Long productId;

    @NotNull(message = "商品名称不能为空")
    private String productName;

    private Long skuId;
    private String skuCode;
    private Integer currentStock;
    private Integer minStock;

    @NotNull(message = "补货数量不能为空")
    private Integer replenishmentQuantity;

    private Integer arrivalQuantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
}
