package com.erplist.order.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.api.dto.CountryOrderCountDTO;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.order.dto.OrderDTO;
import com.erplist.order.dto.OrderDetailVO;
import com.erplist.order.dto.OrderListVO;
import com.erplist.order.dto.OrderQueryDTO;
import com.erplist.api.dto.OrderItemImageDTO;
import com.erplist.order.entity.Order;

import java.time.LocalDate;
import java.util.List;

/**
 * 订单服务接口
 */
public interface OrderService {
    Order createOrder(OrderDTO dto);
    OrderDetailVO getOrderById(Long id);
    Order updateOrder(Long id, OrderDTO dto);
    void deleteOrder(Long id);
    Page<OrderListVO> queryOrders(OrderQueryDTO queryDTO);

    /**
     * 获取销售时序数据（按日、按 SKU 聚合），供 LSTM 补货预测使用
     */
    List<SalesTimeSeriesItemDTO> getSalesTimeSeries(String zid, Long sid, LocalDate startDate, LocalDate endDate, Long skuId);

    /**
     * 查询某公司下有订单的店铺 ID 列表（去重）
     */
    List<Long> getDistinctSidsByZid(String zid);

    /**
     * 按国家统计订单数，供首页地图使用
     */
    List<CountryOrderCountDTO> getOrderStatsByCountry(String zid, Long sid, LocalDate startDate, LocalDate endDate);

    /**
     * 根据订单项 ID 列表查询商品图，供退款列表展示
     */
    List<OrderItemImageDTO> getOrderItemProductImages(List<Long> orderItemIds);
}
