package com.erplist.promotion.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 促销活动实体
 */
@Data
@TableName("promotion")
public class Promotion {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String promotionName;
    private String promotionType;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private BigDecimal discountRate;
    private BigDecimal fullAmount;
    private BigDecimal reductionAmount;
    private Long giftProductId;
    private Integer giftQuantity;
    private Integer status;
    private String description;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @TableLogic
    private Integer deleted;
}
