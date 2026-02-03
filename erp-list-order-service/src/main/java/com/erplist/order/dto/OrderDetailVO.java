package com.erplist.order.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单详情 VO（含订单头 + 订单明细 items）
 */
@Data
public class OrderDetailVO {
    private Long id;
    private String orderNo;
    private Long userId;
    private String zid;
    private Long sid;
    private String countryCode;
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    private BigDecimal promotionDiscountAmount;
    private BigDecimal taxAmount;
    private BigDecimal payAmount;
    private Integer orderStatus;
    private Integer payStatus;
    private LocalDateTime payTime;
    private LocalDateTime deliveryTime;
    private LocalDateTime completeTime;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer deleted;
    /** 订单明细（售卖记录：商品、单价、数量、小计） */
    private List<OrderItemDTO> items;
}
