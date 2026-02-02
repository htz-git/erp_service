package com.erplist.replenishment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 补货明细实体
 */
@Data
@TableName("replenishment_item")
public class ReplenishmentItem {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long replenishmentId;
    private String replenishmentNo;
    private String zid;
    private Long sid;
    private Long productId;
    private String productName;
    private Long skuId;
    private String skuCode;
    private Integer currentStock;
    private Integer minStock;
    private Integer replenishmentQuantity;
    private Integer arrivalQuantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
