package com.erplist.replenishment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.replenishment.dto.InventoryAlertHandleDTO;
import com.erplist.replenishment.dto.InventoryAlertQueryDTO;
import com.erplist.replenishment.entity.InventoryAlert;
import com.erplist.replenishment.service.InventoryAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 库存预警控制器（/inventory-alerts，网关 /api/inventory-alerts 对应）
 */
@RestController
@RequestMapping("/inventory-alerts")
@RequiredArgsConstructor
public class InventoryAlertController {

    private final InventoryAlertService inventoryAlertService;

    @GetMapping
    public Result<Page<InventoryAlert>> query(InventoryAlertQueryDTO queryDTO) {
        Page<InventoryAlert> page = inventoryAlertService.query(queryDTO);
        return Result.success(page);
    }

    @GetMapping("/{id}")
    public Result<InventoryAlert> getById(@PathVariable Long id) {
        InventoryAlert entity = inventoryAlertService.getById(id);
        return Result.success(entity);
    }

    @PutMapping("/{id}/handle")
    public Result<Void> markHandled(@PathVariable Long id, @RequestBody(required = false) InventoryAlertHandleDTO dto) {
        inventoryAlertService.markHandled(id, dto != null ? dto : new InventoryAlertHandleDTO());
        return Result.success();
    }
}
