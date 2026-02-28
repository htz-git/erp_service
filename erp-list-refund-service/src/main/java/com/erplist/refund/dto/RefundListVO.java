package com.erplist.refund.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 退款申请列表 VO（含商品图，供前端展示）
 */
@Data
public class RefundListVO {
    private Long id;
    private String refundNo;
    private Long orderId;
    private String orderNo;
    private Long orderItemId;
    private Long userId;
    private Long paymentId;
    private String paymentNo;
    private String zid;
    private Long sid;
    private BigDecimal refundAmount;
    private Long refundReasonId;
    private String refundReason;
    private Integer refundStatus;
    private LocalDateTime applyTime;
    private LocalDateTime approveTime;
    private Long approverId;
    private String approverName;
    private String approveRemark;
    private LocalDateTime refundTime;
    private String thirdPartyRefundNo;
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    /** 退款商品图（来自订单项，仅商品退款时有；整单退款可为空） */
    private String productImageUrl;
}
