package com.erplist.seller.dto;

import lombok.Data;

/**
 * 店铺查询 DTO（分页）
 */
@Data
public class SellerQueryDTO {
    private String sellerName;
    private String platform;
    private Integer status;
    private Long userId;
    private String zid;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
