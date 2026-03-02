package com.erplist.replenishment.dto;

import lombok.Data;

/**
 * 库存预警分页查询参数
 */
@Data
public class InventoryAlertQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    /** 预警级别：1-低库存，2-缺货 */
    private Integer alertLevel;
    /** 处理状态：0-未处理，1-已处理 */
    private Integer alertStatus;
    private Long productId;
    private Long skuId;
}
