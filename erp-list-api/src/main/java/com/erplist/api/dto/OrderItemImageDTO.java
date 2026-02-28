package com.erplist.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 订单项商品图 DTO（供退款列表等展示）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderItemImageDTO {
    private Long orderItemId;
    private String productImage;
}
