package com.erplist.refund.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 退款申请实体
 */
@Data
@TableName("refund_application")
public class RefundApplication {
    @TableId(type = IdType.AUTO)
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
    @TableLogic
    private Integer deleted;
}
