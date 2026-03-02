package com.erplist.replenishment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 补货计划实体
 */
@Data
@TableName("replenishment_plan")
public class ReplenishmentPlan {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String planName;
    private Long productId;
    private String productName;
    private Long skuId;
    private Long warehouseId;
    private Integer minStock;
    private Integer maxStock;
    private Integer reorderPoint;
    private Integer reorderQuantity;
    /** 计划状态：0-禁用，1-启用 */
    private Integer planStatus;
    private LocalDateTime nextReplenishmentTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @TableLogic
    private Integer deleted;
}
