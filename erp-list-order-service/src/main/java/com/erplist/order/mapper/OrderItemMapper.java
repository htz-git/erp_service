package com.erplist.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.order.entity.OrderItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

/**
 * 订单明细 Mapper
 */
@Mapper
public interface OrderItemMapper extends BaseMapper<OrderItem> {

    /**
     * 按日、按 SKU 聚合销量，供 LSTM 补货预测使用
     */
    List<SalesTimeSeriesItemDTO> selectSalesTimeSeries(
            @Param("zid") String zid,
            @Param("sid") Long sid,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("skuId") Long skuId
    );
}
