package com.erplist.order.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单列表 VO（含首条商品图，供前端列表展示）
 */
@Data
public class OrderListVO {
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

    /** 订单中第一个商品的图片 URL（用于列表展示） */
    private String firstItemImageUrl;
}
