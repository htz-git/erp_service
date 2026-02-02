package com.erplist.refund.dto;

import lombok.Data;

/**
 * 退款申请查询 DTO（分页，zid/sid 多租户）
 */
@Data
public class RefundApplicationQueryDTO {
    private String zid;
    private Long sid;
    private String refundNo;
    private Long orderId;
    private String orderNo;
    private Long userId;
    private Long paymentId;
    private Integer refundStatus;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
