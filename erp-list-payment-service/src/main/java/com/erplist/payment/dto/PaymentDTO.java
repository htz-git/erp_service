package com.erplist.payment.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 支付记录 DTO（创建/更新）
 */
@Data
public class PaymentDTO {
    private Long id;

    @NotBlank(message = "支付单号不能为空")
    private String paymentNo;

    @NotNull(message = "订单ID不能为空")
    private Long orderId;

    @NotBlank(message = "订单号不能为空")
    private String orderNo;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    private String zid;
    private Long sid;

    @NotNull(message = "支付方式ID不能为空")
    private Long paymentMethodId;

    @NotBlank(message = "支付方式名称不能为空")
    private String paymentMethodName;

    @NotNull(message = "支付金额不能为空")
    private BigDecimal amount;

    private Integer paymentStatus;
    private String thirdPartyNo;
    private LocalDateTime payTime;
    private LocalDateTime refundTime;
    private String remark;
}
