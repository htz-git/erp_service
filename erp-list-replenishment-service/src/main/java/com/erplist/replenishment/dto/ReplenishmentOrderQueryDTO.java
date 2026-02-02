package com.erplist.replenishment.dto;

import lombok.Data;

/**
 * 补货单查询 DTO（分页，zid/sid 多租户）
 */
@Data
public class ReplenishmentOrderQueryDTO {
    private String zid;
    private Long sid;
    private String replenishmentNo;
    private Long warehouseId;
    private Integer replenishmentStatus;
    private Long operatorId;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
