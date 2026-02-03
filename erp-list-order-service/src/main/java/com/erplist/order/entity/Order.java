package com.erplist.order.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单实体（表名为 MySQL 保留字 order，需转义）
 */
@Data
@TableName("`order`")
public class Order {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String orderNo;
    private Long userId;
    private String zid;
    private Long sid;
    /** 配送国家/地区代码（如 ISO 3166-1 alpha-2） */
    private String countryCode;
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    /** 促销折扣金额（仅记录展示） */
    private BigDecimal promotionDiscountAmount;
    /** 税费（仅记录展示） */
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
    @TableLogic
    private Integer deleted;
}
