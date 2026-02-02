package com.erplist.promotion.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 促销活动 DTO（创建/更新）
 */
@Data
public class PromotionDTO {
    private Long id;
    @NotBlank(message = "促销活动名称不能为空")
    private String promotionName;
    @NotBlank(message = "促销类型不能为空")
    private String promotionType;
    @NotNull(message = "开始时间不能为空")
    private LocalDateTime startTime;
    @NotNull(message = "结束时间不能为空")
    private LocalDateTime endTime;
    private BigDecimal discountRate;
    private BigDecimal fullAmount;
    private BigDecimal reductionAmount;
    private Long giftProductId;
    private Integer giftQuantity;
    private Integer status;
    private String description;
}
