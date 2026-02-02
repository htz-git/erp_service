package com.erplist.promotion.dto;

import lombok.Data;

/**
 * 优惠券查询 DTO（分页）
 */
@Data
public class CouponQueryDTO {
    private String couponName;
    private String couponType;
    private Integer status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
