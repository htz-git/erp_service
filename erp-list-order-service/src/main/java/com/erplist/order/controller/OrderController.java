package com.erplist.order.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.api.dto.CountryOrderCountDTO;
import com.erplist.api.dto.SalesTimeSeriesItemDTO;
import com.erplist.order.dto.OrderDTO;
import com.erplist.order.dto.OrderDetailVO;
import com.erplist.order.dto.OrderQueryDTO;
import com.erplist.order.entity.Order;
import com.erplist.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * 订单控制器
 */
@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    public Result<Order> createOrder(@Validated @RequestBody OrderDTO dto) {
        Order order = orderService.createOrder(dto);
        return Result.success(order);
    }

    @GetMapping("/{id}")
    public Result<OrderDetailVO> getOrderById(@PathVariable Long id) {
        OrderDetailVO vo = orderService.getOrderById(id);
        return Result.success(vo);
    }

    @PutMapping("/{id}")
    public Result<Order> updateOrder(@PathVariable Long id, @Validated @RequestBody OrderDTO dto) {
        Order order = orderService.updateOrder(id, dto);
        return Result.success(order);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteOrder(@PathVariable Long id) {
        orderService.deleteOrder(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<Order>> queryOrders(OrderQueryDTO queryDTO) {
        Page<Order> page = orderService.queryOrders(queryDTO);
        return Result.success(page);
    }

    /**
     * 查询某公司下有订单的店铺 ID 列表（去重），供补货建议“全部店铺”使用
     */
    @GetMapping("/distinct-sids")
    public Result<List<Long>> getDistinctSids(@RequestParam(value = "zid", required = false) String zid) {
        List<Long> list = orderService.getDistinctSidsByZid(zid);
        return Result.success(list);
    }

    /**
     * 获取销售时序数据（按日、按 SKU 聚合），供 LSTM 补货预测使用
     */
    @GetMapping("/sales-timeseries")
    public Result<List<SalesTimeSeriesItemDTO>> getSalesTimeSeries(
            @RequestParam(value = "zid", required = false) String zid,
            @RequestParam(value = "sid", required = false) Long sid,
            @RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(value = "skuId", required = false) Long skuId) {
        List<SalesTimeSeriesItemDTO> list = orderService.getSalesTimeSeries(zid, sid, startDate, endDate, skuId);
        return Result.success(list);
    }

    /**
     * 按国家统计订单数，供首页地图使用
     */
    @GetMapping("/stats-by-country")
    public Result<List<CountryOrderCountDTO>> getOrderStatsByCountry(
            @RequestParam(value = "zid", required = false) String zid,
            @RequestParam(value = "sid", required = false) Long sid,
            @RequestParam(value = "startDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(value = "endDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<CountryOrderCountDTO> list = orderService.getOrderStatsByCountry(zid, sid, startDate, endDate);
        return Result.success(list);
    }
}
