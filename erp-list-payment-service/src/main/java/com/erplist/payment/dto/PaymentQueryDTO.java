package com.erplist.payment.dto;

import lombok.Data;

/**
 * 支付记录查询 DTO（分页）
 */
@Data
public class PaymentQueryDTO {
    private String paymentNo;
    private Long orderId;
    private String orderNo;
    private Long userId;
    private String zid;
    private Long sid;
    private Integer paymentStatus;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
