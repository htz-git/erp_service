package com.erplist.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.order.dto.OrderDTO;
import com.erplist.order.dto.OrderItemDTO;
import com.erplist.order.dto.OrderQueryDTO;
import com.erplist.order.entity.Order;
import com.erplist.order.entity.OrderItem;
import com.erplist.order.mapper.OrderItemMapper;
import com.erplist.order.mapper.OrderMapper;
import com.erplist.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 订单服务实现（支持 zid/sid 多租户过滤）
 */
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Order createOrder(OrderDTO dto) {
        Order order = new Order();
        BeanUtils.copyProperties(dto, order, "id", "items");
        String zid = dto.getZid() != null ? dto.getZid() : UserContext.getZid();
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        order.setZid(zid);
        order.setSid(sid);
        if (!StringUtils.hasText(order.getOrderNo())) {
            order.setOrderNo("ORD" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        order.setOrderStatus(order.getOrderStatus() != null ? order.getOrderStatus() : 0);
        order.setPayStatus(order.getPayStatus() != null ? order.getPayStatus() : 0);
        order.setDiscountAmount(order.getDiscountAmount() != null ? order.getDiscountAmount() : java.math.BigDecimal.ZERO);
        orderMapper.insert(order);

        if (dto.getItems() != null && !dto.getItems().isEmpty()) {
            for (OrderItemDTO itemDto : dto.getItems()) {
                OrderItem item = new OrderItem();
                BeanUtils.copyProperties(itemDto, item);
                item.setOrderId(order.getId());
                item.setOrderNo(order.getOrderNo());
                item.setZid(zid);
                item.setSid(sid);
                if (item.getTotalPrice() == null && item.getPrice() != null && item.getQuantity() != null) {
                    item.setTotalPrice(item.getPrice().multiply(new java.math.BigDecimal(item.getQuantity())));
                }
                orderItemMapper.insert(item);
            }
        }
        return order;
    }

    @Override
    public Order getOrderById(Long id) {
        Order order = orderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        return order;
    }

    @Override
    public Order updateOrder(Long id, OrderDTO dto) {
        Order order = orderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        BeanUtils.copyProperties(dto, order, "id", "orderNo", "createTime");
        orderMapper.updateById(order);
        return order;
    }

    @Override
    public void deleteOrder(Long id) {
        Order order = orderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        orderMapper.deleteById(id);
    }

    @Override
    public Page<Order> queryOrders(OrderQueryDTO queryDTO) {
        Page<Order> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        String zid = queryDTO.getZid() != null ? queryDTO.getZid() : UserContext.getZid();
        Long sid = queryDTO.getSid();
        if (sid == null) {
            sid = UserContext.getSid();
        }
        if (StringUtils.hasText(zid)) {
            wrapper.eq(Order::getZid, zid);
        }
        if (sid != null) {
            wrapper.eq(Order::getSid, sid);
        }
        if (queryDTO.getUserId() != null) {
            wrapper.eq(Order::getUserId, queryDTO.getUserId());
        }
        if (StringUtils.hasText(queryDTO.getOrderNo())) {
            wrapper.eq(Order::getOrderNo, queryDTO.getOrderNo());
        }
        if (queryDTO.getOrderStatus() != null) {
            wrapper.eq(Order::getOrderStatus, queryDTO.getOrderStatus());
        }
        if (queryDTO.getPayStatus() != null) {
            wrapper.eq(Order::getPayStatus, queryDTO.getPayStatus());
        }
        wrapper.orderByDesc(Order::getCreateTime);
        return orderMapper.selectPage(page, wrapper);
    }

    @Override
    public List<SalesTimeSeriesItemDTO> getSalesTimeSeries(String zid, Long sid, LocalDate startDate, LocalDate endDate, Long skuId) {
        String effectiveZid = StringUtils.hasText(zid) ? zid : UserContext.getZid();
        Long effectiveSid = sid != null ? sid : UserContext.getSid();
        return orderItemMapper.selectSalesTimeSeries(effectiveZid, effectiveSid, startDate, endDate, skuId);
    }
}
