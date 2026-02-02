package com.erplist.promotion.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 优惠券 DTO（创建/更新）
 */
@Data
public class CouponDTO {
    private Long id;
    @NotBlank(message = "优惠券名称不能为空")
    private String couponName;
    @NotBlank(message = "优惠券类型不能为空")
    private String couponType;
    private BigDecimal discountRate;
    private BigDecimal discountAmount;
    private BigDecimal minAmount;
    private Integer totalCount;
    @NotNull(message = "开始时间不能为空")
    private LocalDateTime startTime;
    @NotNull(message = "结束时间不能为空")
    private LocalDateTime endTime;
    private Integer status;
    private String description;
}
