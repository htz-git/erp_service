package com.erplist.order.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单 DTO（创建/更新）
 */
@Data
public class OrderDTO {
    private Long id;
    private String orderNo;
    @NotNull(message = "用户ID不能为空")
    private Long userId;
    private String zid;
    private Long sid;
    @NotNull(message = "订单总金额不能为空")
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    @NotNull(message = "实付金额不能为空")
    private BigDecimal payAmount;
    private Integer orderStatus;
    private Integer payStatus;
    private LocalDateTime payTime;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String remark;
    /** 订单明细 */
    private List<OrderItemDTO> items;
}
