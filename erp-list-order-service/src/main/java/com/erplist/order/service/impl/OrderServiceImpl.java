package com.erplist.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.api.dto.CountryOrderCountDTO;
import com.erplist.api.dto.OrderItemImageDTO;
import com.erplist.api.dto.ProductImageDTO;
import com.erplist.api.dto.ProductImageDTO;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.order.dto.OrderDTO;
import com.erplist.order.dto.OrderDetailVO;
import com.erplist.order.dto.OrderItemDTO;
import com.erplist.order.dto.OrderListVO;
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
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

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
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的订单");
        }
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        Order order = new Order();
        BeanUtils.copyProperties(dto, order, "id", "items");
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
        ensureSameZid(order.getZid());
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
        ensureSameZid(order.getZid());
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
        ensureSameZid(order.getZid());
        orderMapper.deleteById(id);
    }

    @Override
    public Page<OrderListVO> queryOrders(OrderQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的订单");
        }
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        Page<Order> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Order::getZid, zid);
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
        if (queryDTO.getCountryCodes() != null && !queryDTO.getCountryCodes().isEmpty()) {
            wrapper.in(Order::getCountryCode, queryDTO.getCountryCodes());
        }
        if (queryDTO.getCreateTimeStart() != null) {
            wrapper.ge(Order::getCreateTime, queryDTO.getCreateTimeStart().atStartOfDay());
        }
        if (queryDTO.getCreateTimeEnd() != null) {
            wrapper.le(Order::getCreateTime, queryDTO.getCreateTimeEnd().atTime(LocalTime.MAX));
        }
        wrapper.orderByAsc(Order::getId);
        Page<Order> orderPage = orderMapper.selectPage(page, wrapper);
        List<Order> records = orderPage.getRecords();
        if (records == null || records.isEmpty()) {
            Page<OrderListVO> voPage = new Page<>(orderPage.getCurrent(), orderPage.getSize(), orderPage.getTotal());
            voPage.setRecords(new ArrayList<>());
            return voPage;
        }
        List<Long> orderIds = records.stream().map(Order::getId).collect(Collectors.toList());
        LambdaQueryWrapper<OrderItem> itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.in(OrderItem::getOrderId, orderIds).orderByAsc(OrderItem::getOrderId).orderByAsc(OrderItem::getId);
        List<OrderItem> items = orderItemMapper.selectList(itemWrapper);
        Map<Long, String> orderIdToFirstImage = new LinkedHashMap<>();
        if (items != null) {
            for (OrderItem item : items) {
                orderIdToFirstImage.putIfAbsent(item.getOrderId(), item.getProductImage());
            }
        }
        List<OrderListVO> voList = new ArrayList<>();
        for (Order order : records) {
            OrderListVO vo = new OrderListVO();
            BeanUtils.copyProperties(order, vo);
            vo.setFirstItemImageUrl(orderIdToFirstImage.get(order.getId()));
            voList.add(vo);
        }
        Page<OrderListVO> voPage = new Page<>(orderPage.getCurrent(), orderPage.getSize(), orderPage.getTotal());
        voPage.setRecords(voList);
        return voPage;
    }

    @Override
    public List<SalesTimeSeriesItemDTO> getSalesTimeSeries(String zid, Long sid, LocalDate startDate, LocalDate endDate, Long skuId) {
        String effectiveZid = StringUtils.hasText(zid) ? zid : UserContext.getZid();
        if (!StringUtils.hasText(effectiveZid)) {
            throw new BusinessException("未登录或缺少租户信息");
        }
        Long effectiveSid = sid != null ? sid : UserContext.getSid();
        return orderItemMapper.selectSalesTimeSeries(effectiveZid, effectiveSid, startDate, endDate, skuId);
    }

    @Override
    public List<Long> getDistinctSidsByZid(String zid) {
        String effectiveZid = StringUtils.hasText(zid) ? zid : UserContext.getZid();
        if (!StringUtils.hasText(effectiveZid)) {
            return Collections.emptyList();
        }
        List<Long> list = orderItemMapper.selectDistinctSidByZid(effectiveZid);
        return list != null ? list : Collections.emptyList();
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
        if (!StringUtils.hasText(effectiveZid)) {
            throw new BusinessException("未登录或缺少租户信息");
        }
        Long effectiveSid = sid != null ? sid : UserContext.getSid();
        List<CountryOrderCountDTO> list = orderMapper.selectOrderCountByCountry(effectiveZid, effectiveSid, startDate, endDate);
        for (CountryOrderCountDTO dto : list) {
            if (dto.getCountryCode() != null && dto.getCountryName() == null) {
                dto.setCountryName(COUNTRY_NAME_MAP.getOrDefault(dto.getCountryCode().toUpperCase(), dto.getCountryCode()));
            }
        }
        return list;
    }

    @Override
    public List<OrderItemImageDTO> getOrderItemProductImages(List<Long> orderItemIds) {
        if (orderItemIds == null || orderItemIds.isEmpty()) {
            return Collections.emptyList();
        }
        LambdaQueryWrapper<OrderItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(OrderItem::getId, orderItemIds).select(OrderItem::getId, OrderItem::getProductImage);
        List<OrderItem> items = orderItemMapper.selectList(wrapper);
        if (items == null || items.isEmpty()) {
            return Collections.emptyList();
        }
        return items.stream()
            .map(item -> new OrderItemImageDTO(item.getId(), item.getProductImage()))
            .collect(Collectors.toList());
    }

    @Override
    public List<ProductImageDTO> getProductImagesByProductIds(List<Long> productIds) {
        if (productIds == null || productIds.isEmpty()) {
            return Collections.emptyList();
        }
        LambdaQueryWrapper<OrderItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(OrderItem::getProductId, productIds)
                .select(OrderItem::getProductId, OrderItem::getProductImage)
                .last("LIMIT 10000");
        List<OrderItem> items = orderItemMapper.selectList(wrapper);
        if (items == null || items.isEmpty()) {
            return Collections.emptyList();
        }
        Map<Long, String> map = new LinkedHashMap<>();
        for (OrderItem item : items) {
            if (item.getProductId() != null && !map.containsKey(item.getProductId()) && StringUtils.hasText(item.getProductImage())) {
                map.put(item.getProductId(), item.getProductImage());
            }
        }
        return map.entrySet().stream()
                .map(e -> new ProductImageDTO(e.getKey(), e.getValue()))
                .collect(Collectors.toList());
    }

    private void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该订单");
        }
    }
}
