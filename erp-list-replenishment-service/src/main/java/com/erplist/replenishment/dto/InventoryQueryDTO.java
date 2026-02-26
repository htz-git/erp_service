package com.erplist.replenishment.dto;

import lombok.Data;

/**
 * 库存分页查询参数（zid 由上下文填充）
 */
@Data
public class InventoryQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    /** 店铺ID，不传则不过滤 */
    private Long sid;
    private String skuCode;
    private String keyword;
}
