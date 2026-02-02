package com.erplist.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

/**
 * 销售时序数据 DTO（供 LSTM 补货预测使用）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SalesTimeSeriesItemDTO {

    /** 日期（按日聚合） */
    private LocalDate date;
    /** SKU ID */
    private Long skuId;
    /** SKU 编码 */
    private String skuCode;
    /** 商品名称 */
    private String productName;
    /** 商品 ID */
    private Long productId;
    /** 当日销售数量 */
    private Integer quantity;

    /**
     * 单 SKU 的时间序列（按日期排序的每日销量列表，供 LSTM 输入）
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SkuTimeSeries {
        private Long skuId;
        private String skuCode;
        private String productName;
        private Long productId;
        /** 按日期升序的每日销量 [qty1, qty2, ...] */
        private List<Double> values;
        /** 对应日期 [date1, date2, ...] */
        private List<String> dates;
    }
}
