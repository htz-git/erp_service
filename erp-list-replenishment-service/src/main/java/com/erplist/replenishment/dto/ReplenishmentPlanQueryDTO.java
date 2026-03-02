package com.erplist.replenishment.dto;

import lombok.Data;

/**
 * 补货计划分页查询参数
 */
@Data
public class ReplenishmentPlanQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    private String planName;
    private Long productId;
    private Long skuId;
    /** 计划状态：0-禁用，1-启用 */
    private Integer planStatus;
}
