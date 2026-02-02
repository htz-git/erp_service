package com.erplist.replenishment.dto;

import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/**
 * 补货建议查询参数（LSTM 基于历史销售时序预测）
 */
@Data
public class ReplenishmentSuggestionQueryDTO {

    /** 历史数据开始日期，默认 30 天前 */
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate startDate;
    /** 历史数据结束日期，默认昨天 */
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate endDate;
    /** 预测未来天数，默认 7 */
    private Integer forecastDays = 7;
}
