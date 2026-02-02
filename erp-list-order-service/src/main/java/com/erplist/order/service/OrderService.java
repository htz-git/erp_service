package com.erplist.order.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.order.dto.OrderDTO;
import com.erplist.order.dto.OrderQueryDTO;
import com.erplist.order.entity.Order;

/**
 * 订单服务接口
 */
public interface OrderService {
    Order createOrder(OrderDTO dto);
    Order getOrderById(Long id);
    Order updateOrder(Long id, OrderDTO dto);
    void deleteOrder(Long id);
    Page<Order> queryOrders(OrderQueryDTO queryDTO);
}
