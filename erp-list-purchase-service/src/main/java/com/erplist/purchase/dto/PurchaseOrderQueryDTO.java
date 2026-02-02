package com.erplist.purchase.dto;

import lombok.Data;

/**
 * 采购单查询 DTO（分页，zid/sid 多租户）
 */
@Data
public class PurchaseOrderQueryDTO {
    private String zid;
    private Long sid;
    private String purchaseNo;
    private Long supplierId;
    private Integer purchaseStatus;
    private Long purchaserId;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
