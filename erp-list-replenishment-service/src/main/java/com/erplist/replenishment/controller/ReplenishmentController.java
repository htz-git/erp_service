package com.erplist.replenishment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.replenishment.dto.ReplenishmentOrderDTO;
import com.erplist.replenishment.dto.ReplenishmentOrderQueryDTO;
import com.erplist.replenishment.dto.ReplenishmentSuggestionDTO;
import com.erplist.replenishment.dto.ReplenishmentSuggestionQueryDTO;
import com.erplist.replenishment.entity.ReplenishmentItem;
import com.erplist.replenishment.entity.ReplenishmentOrder;
import com.erplist.replenishment.service.ReplenishmentOrderService;
import com.erplist.replenishment.service.ReplenishmentSuggestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 补货控制器（/replenishments，与网关 /api/replenishments 对应）
 */
@RestController
@RequestMapping("/replenishments")
@RequiredArgsConstructor
public class ReplenishmentController {

    private final ReplenishmentOrderService replenishmentOrderService;
    private final ReplenishmentSuggestionService replenishmentSuggestionService;

    @PostMapping
    public Result<ReplenishmentOrder> create(@Validated @RequestBody ReplenishmentOrderDTO dto) {
        ReplenishmentOrder order = replenishmentOrderService.createReplenishmentOrder(dto);
        return Result.success(order);
    }

    @GetMapping("/{id}")
    public Result<ReplenishmentOrder> getById(@PathVariable Long id) {
        ReplenishmentOrder order = replenishmentOrderService.getReplenishmentOrderById(id);
        return Result.success(order);
    }

    @GetMapping("/{id}/items")
    public Result<List<ReplenishmentItem>> getItems(@PathVariable Long id) {
        List<ReplenishmentItem> items = replenishmentOrderService.getItemsByReplenishmentId(id);
        return Result.success(items);
    }

    @PutMapping("/{id}")
    public Result<ReplenishmentOrder> update(@PathVariable Long id, @Validated @RequestBody ReplenishmentOrderDTO dto) {
        ReplenishmentOrder order = replenishmentOrderService.updateReplenishmentOrder(id, dto);
        return Result.success(order);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        replenishmentOrderService.deleteReplenishmentOrder(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<ReplenishmentOrder>> query(ReplenishmentOrderQueryDTO queryDTO) {
        Page<ReplenishmentOrder> page = replenishmentOrderService.queryReplenishmentOrders(queryDTO);
        return Result.success(page);
    }

    /**
     * 基于 LSTM 对当前用户订单销售时序的预测，获取补货建议
     */
    @GetMapping("/suggestions")
    public Result<List<ReplenishmentSuggestionDTO>> getSuggestions(ReplenishmentSuggestionQueryDTO queryDTO) {
        List<ReplenishmentSuggestionDTO> list = replenishmentSuggestionService.getSuggestions(queryDTO);
        return Result.success(list);
    }
}
