package com.erplist.payment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 支付方式实体
 */
@Data
@TableName("payment_method")
public class PaymentMethod {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String methodName;
    private String methodCode;
    private String methodType;
    private String icon;
    private Integer sortOrder;
    private Integer status;
    private String config;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @TableLogic
    private Integer deleted;
}
