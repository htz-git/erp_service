package com.erplist.order.dto;

import lombok.Data;

/**
 * 订单查询 DTO（分页，支持 zid/sid）
 */
@Data
public class OrderQueryDTO {
    private String orderNo;
    private Long userId;
    private String zid;
    private Long sid;
    /** 国家代码筛选 */
    private String countryCode;
    private Integer orderStatus;
    private Integer payStatus;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
