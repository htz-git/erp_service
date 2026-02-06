package com.erplist.replenishment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.replenishment.dto.InventoryDTO;
import com.erplist.replenishment.dto.InventoryQueryDTO;
import com.erplist.replenishment.entity.Inventory;
import com.erplist.replenishment.service.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 库存控制器（/inventories，网关 /api/inventories 对应）
 */
@RestController
@RequestMapping("/inventories")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    @GetMapping
    public Result<Page<Inventory>> query(InventoryQueryDTO queryDTO) {
        Page<Inventory> page = inventoryService.query(queryDTO);
        return Result.success(page);
    }

    @GetMapping("/{id}")
    public Result<Inventory> getById(@PathVariable Long id) {
        Inventory entity = inventoryService.getById(id);
        return Result.success(entity);
    }

    @PostMapping
    public Result<Inventory> create(@Validated @RequestBody InventoryDTO dto) {
        Inventory entity = inventoryService.create(dto);
        return Result.success(entity);
    }

    @PutMapping("/{id}")
    public Result<Inventory> update(@PathVariable Long id, @Validated @RequestBody InventoryDTO dto) {
        Inventory entity = inventoryService.update(id, dto);
        return Result.success(entity);
    }
}
