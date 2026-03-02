package com.erplist.replenishment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 库存预警实体
 */
@Data
@TableName("inventory_alert")
public class InventoryAlert {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long productId;
    private String productName;
    private Long skuId;
    private String skuCode;
    private Long warehouseId;
    private String warehouseName;
    private Integer currentStock;
    private Integer minStock;
    /** 预警级别：1-低库存，2-缺货 */
    private Integer alertLevel;
    /** 处理状态：0-未处理，1-已处理 */
    private Integer alertStatus;
    private Long handlerId;
    private String handlerName;
    private LocalDateTime handleTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
