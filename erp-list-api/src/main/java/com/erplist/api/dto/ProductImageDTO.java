package com.erplist.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 按商品 ID 维度的商品图 DTO（供库存、采购单等展示）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductImageDTO {
    private Long productId;
    private String productImage;
}
