package com.erplist.refund.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 退款申请 DTO（创建/更新）
 */
@Data
public class RefundApplicationDTO {
    private Long id;
    private String refundNo;

    @NotNull(message = "订单ID不能为空")
    private Long orderId;

    private String orderNo;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotNull(message = "支付ID不能为空")
    private Long paymentId;

    private String paymentNo;
    private String zid;
    private Long sid;

    @NotNull(message = "退款金额不能为空")
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
}
