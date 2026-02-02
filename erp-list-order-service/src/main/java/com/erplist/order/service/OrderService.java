package com.erplist.order.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.order.dto.OrderDTO;
import com.erplist.order.dto.OrderQueryDTO;
import com.erplist.order.entity.Order;

import java.time.LocalDate;
import java.util.List;

/**
 * 订单服务接口
 */
public interface OrderService {
    Order createOrder(OrderDTO dto);
    Order getOrderById(Long id);
    Order updateOrder(Long id, OrderDTO dto);
    void deleteOrder(Long id);
    Page<Order> queryOrders(OrderQueryDTO queryDTO);

    /**
     * 获取销售时序数据（按日、按 SKU 聚合），供 LSTM 补货预测使用
     */
    List<SalesTimeSeriesItemDTO> getSalesTimeSeries(String zid, Long sid, LocalDate startDate, LocalDate endDate, Long skuId);
}
