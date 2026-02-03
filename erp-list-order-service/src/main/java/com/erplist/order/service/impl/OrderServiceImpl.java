package com.erplist.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.api.dto.CountryOrderCountDTO;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.order.dto.OrderDTO;
import com.erplist.order.dto.OrderDetailVO;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
        if (StringUtils.hasText(dto.getCountryCode())) {
            order.setCountryCode(dto.getCountryCode());
        }
        if (!StringUtils.hasText(order.getOrderNo())) {
            order.setOrderNo("ORD" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        order.setOrderStatus(order.getOrderStatus() != null ? order.getOrderStatus() : 0);
        order.setPayStatus(order.getPayStatus() != null ? order.getPayStatus() : 0);
        order.setDiscountAmount(order.getDiscountAmount() != null ? order.getDiscountAmount() : java.math.BigDecimal.ZERO);
        order.setPromotionDiscountAmount(order.getPromotionDiscountAmount() != null ? order.getPromotionDiscountAmount() : java.math.BigDecimal.ZERO);
        order.setTaxAmount(order.getTaxAmount() != null ? order.getTaxAmount() : java.math.BigDecimal.ZERO);
        orderMapper.insert(order);

        if (dto.getItems() != null && !dto.getItems().isEmpty()) {
            for (OrderItemDTO itemDto : dto.getItems()) {
                OrderItem item = new OrderItem();
                BeanUtils.copyProperties(itemDto, item);
                item.setOrderId(order.getId());
                item.setOrderNo(order.getOrderNo());
                item.setZid(zid);
                item.setSid(sid);
                if (itemDto.getCompanyProductId() != null) {
                    item.setCompanyProductId(itemDto.getCompanyProductId());
                }
                if (item.getTotalPrice() == null && item.getPrice() != null && item.getQuantity() != null) {
                    item.setTotalPrice(item.getPrice().multiply(new java.math.BigDecimal(item.getQuantity())));
                }
                orderItemMapper.insert(item);
            }
        }
        return order;
    }

    @Override
    public OrderDetailVO getOrderById(Long id) {
        Order order = orderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        OrderDetailVO vo = new OrderDetailVO();
        BeanUtils.copyProperties(order, vo);
        LambdaQueryWrapper<OrderItem> itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(OrderItem::getOrderId, id).orderByAsc(OrderItem::getId);
        List<OrderItem> itemList = orderItemMapper.selectList(itemWrapper);
        List<OrderItemDTO> itemDtos = new ArrayList<>();
        for (OrderItem item : itemList) {
            OrderItemDTO dto = new OrderItemDTO();
            BeanUtils.copyProperties(item, dto);
            itemDtos.add(dto);
        }
        vo.setItems(itemDtos);
        return vo;
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
        if (StringUtils.hasText(queryDTO.getCountryCode())) {
            wrapper.eq(Order::getCountryCode, queryDTO.getCountryCode());
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

    private static final Map<String, String> COUNTRY_NAME_MAP = new HashMap<String, String>() {{
        put("US", "美国"); put("DE", "德国"); put("UK", "英国"); put("FR", "法国"); put("IT", "意大利");
        put("ES", "西班牙"); put("JP", "日本"); put("CA", "加拿大"); put("AU", "澳大利亚"); put("IN", "印度");
        put("MX", "墨西哥"); put("BR", "巴西"); put("NL", "荷兰"); put("PL", "波兰"); put("TR", "土耳其");
        put("CN", "中国"); put("KR", "韩国"); put("SG", "新加坡"); put("AE", "阿联酋"); put("SA", "沙特");
    }};

    @Override
    public List<CountryOrderCountDTO> getOrderStatsByCountry(String zid, Long sid, LocalDate startDate, LocalDate endDate) {
        String effectiveZid = StringUtils.hasText(zid) ? zid : UserContext.getZid();
        Long effectiveSid = sid != null ? sid : UserContext.getSid();
        List<CountryOrderCountDTO> list = orderMapper.selectOrderCountByCountry(effectiveZid, effectiveSid, startDate, endDate);
        for (CountryOrderCountDTO dto : list) {
            if (dto.getCountryCode() != null && dto.getCountryName() == null) {
                dto.setCountryName(COUNTRY_NAME_MAP.getOrDefault(dto.getCountryCode().toUpperCase(), dto.getCountryCode()));
            }
        }
        return list;
    }
}
