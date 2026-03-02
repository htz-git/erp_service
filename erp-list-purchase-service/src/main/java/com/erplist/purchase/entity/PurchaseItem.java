package com.erplist.purchase.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 采购明细实体
 */
@Data
@TableName("purchase_item")
public class PurchaseItem {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long purchaseId;
    private String purchaseNo;
    private String zid;
    private Long sid;
    private Long productId;
    private String productName;
    private Long skuId;
    private String skuCode;
    private BigDecimal purchasePrice;
    private Integer purchaseQuantity;
    private Integer arrivalQuantity;
    private BigDecimal totalPrice;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    /** 商品图（详情展示时通过订单服务填充，非表字段） */
    @TableField(exist = false)
    private String productImageUrl;
}
