package com.erplist.replenishment.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 补货计划创建/更新 DTO
 */
@Data
public class ReplenishmentPlanDTO {
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
}
