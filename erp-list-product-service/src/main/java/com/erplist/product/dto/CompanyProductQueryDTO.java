package com.erplist.product.dto;

import lombok.Data;

/**
 * 公司商品查询 DTO（分页）
 */
@Data
public class CompanyProductQueryDTO {
    private String zid;
    private Long sid;
    private String productName;
    private String productCode;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
