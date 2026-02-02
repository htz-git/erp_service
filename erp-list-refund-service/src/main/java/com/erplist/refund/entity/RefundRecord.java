package com.erplist.refund.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 退款记录实体
 */
@Data
@TableName("refund_record")
public class RefundRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long refundId;
    private String refundNo;
    private BigDecimal refundAmount;
    private Integer refundStatus;
    private String thirdPartyRefundNo;
    private LocalDateTime refundTime;
    private String errorMessage;
    private LocalDateTime createTime;
}
