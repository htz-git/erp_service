package com.erplist.payment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 支付流水实体
 */
@Data
@TableName("payment_flow")
public class PaymentFlow {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long paymentId;
    private String paymentNo;
    private String flowType;
    private BigDecimal amount;
    private Integer flowStatus;
    private String thirdPartyNo;
    private String requestData;
    private String responseData;
    private String errorMessage;
    private LocalDateTime createTime;
}
