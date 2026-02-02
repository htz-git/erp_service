package com.erplist.purchase.dto;

import lombok.Data;

/**
 * 供应商查询 DTO（分页）
 */
@Data
public class SupplierQueryDTO {
    private String supplierName;
    private String supplierCode;
    private Integer status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
