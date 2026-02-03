package com.erplist.order.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 订单明细 DTO
 */
@Data
public class OrderItemDTO {
    private Long id;
    /** 关联公司商品ID（company_product.id） */
    private Long companyProductId;
    private Long productId;
    @NotNull(message = "商品名称不能为空")
    private String productName;
    private String productImage;
    private Long skuId;
    private String skuCode;
    @NotNull(message = "单价不能为空")
    private BigDecimal price;
    @NotNull(message = "数量不能为空")
    private Integer quantity;
    private BigDecimal totalPrice;
}
