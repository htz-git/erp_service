package com.erplist.promotion.dto;

import lombok.Data;

/**
 * 促销活动查询 DTO（分页）
 */
@Data
public class PromotionQueryDTO {
    private String promotionName;
    private String promotionType;
    private Integer status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
