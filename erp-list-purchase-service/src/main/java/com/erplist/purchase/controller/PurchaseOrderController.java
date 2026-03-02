package com.erplist.purchase.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.purchase.dto.CreatePurchaseFromSuggestionsRequest;
import com.erplist.purchase.dto.PurchaseOrderDTO;
import com.erplist.purchase.dto.PurchaseOrderQueryDTO;
import com.erplist.purchase.entity.PurchaseItem;
import com.erplist.purchase.entity.PurchaseOrder;
import com.erplist.purchase.service.PurchaseOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 采购单控制器（网关路径 /api/purchases）
 */
@RestController
@RequestMapping("/purchases")
@RequiredArgsConstructor
public class PurchaseOrderController {

    private final PurchaseOrderService purchaseOrderService;

    @PostMapping
    public Result<PurchaseOrder> createPurchaseOrder(@Validated @RequestBody PurchaseOrderDTO dto) {
        PurchaseOrder order = purchaseOrderService.createPurchaseOrder(dto);
        return Result.success(order);
    }

    @PostMapping("/from-suggestions")
    public Result<PurchaseOrder> createPurchaseOrderFromSuggestions(@Validated @RequestBody CreatePurchaseFromSuggestionsRequest request) {
        PurchaseOrder order = purchaseOrderService.createPurchaseOrderFromSuggestions(request);
        return Result.success(order);
    }

    @PutMapping("/{id}/approve")
    public Result<Void> approvePurchaseOrder(@PathVariable Long id) {
        purchaseOrderService.approvePurchaseOrder(id);
        return Result.success();
    }

    @GetMapping("/{id}")
    public Result<PurchaseOrder> getPurchaseOrderById(@PathVariable Long id) {
        PurchaseOrder order = purchaseOrderService.getPurchaseOrderById(id);
        return Result.success(order);
    }

    @GetMapping("/{id}/items")
    public Result<List<PurchaseItem>> getItemsByPurchaseId(@PathVariable Long id) {
        List<PurchaseItem> items = purchaseOrderService.getItemsByPurchaseId(id);
        return Result.success(items);
    }

    @GetMapping("/{id}/detail")
    public Result<Map<String, Object>> getPurchaseOrderDetail(@PathVariable Long id) {
        PurchaseOrder order = purchaseOrderService.getPurchaseOrderById(id);
        List<PurchaseItem> items = purchaseOrderService.getItemsByPurchaseId(id);
        purchaseOrderService.fillProductImageForItems(items);
        Map<String, Object> detail = new HashMap<>();
        detail.put("order", order);
        detail.put("items", items);
        return Result.success(detail);
    }

    @PutMapping("/{id}")
    public Result<PurchaseOrder> updatePurchaseOrder(@PathVariable Long id, @Validated @RequestBody PurchaseOrderDTO dto) {
        PurchaseOrder order = purchaseOrderService.updatePurchaseOrder(id, dto);
        return Result.success(order);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deletePurchaseOrder(@PathVariable Long id) {
        purchaseOrderService.deletePurchaseOrder(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<PurchaseOrder>> queryPurchaseOrders(PurchaseOrderQueryDTO queryDTO) {
        Page<PurchaseOrder> page = purchaseOrderService.queryPurchaseOrders(queryDTO);
        return Result.success(page);
    }
}
