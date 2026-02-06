package com.erplist.replenishment.dto;

import lombok.Data;

/**
 * 库存 DTO（创建/更新）
 */
@Data
public class InventoryDTO {
    private Long productId;
    private String productName;
    private Long skuId;
    private String skuCode;
    /** 当前库存，创建时默认 0 */
    private Integer currentStock;
    /** 最低库存，创建时默认 0 */
    private Integer minStock;
}
