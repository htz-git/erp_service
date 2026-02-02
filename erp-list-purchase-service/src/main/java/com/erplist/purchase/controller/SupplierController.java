package com.erplist.purchase.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.purchase.dto.SupplierDTO;
import com.erplist.purchase.dto.SupplierQueryDTO;
import com.erplist.purchase.entity.Supplier;
import com.erplist.purchase.service.SupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 供应商控制器（网关路径 /api/suppliers）
 */
@RestController
@RequestMapping("/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;

    @PostMapping
    public Result<Supplier> createSupplier(@Validated @RequestBody SupplierDTO dto) {
        Supplier supplier = supplierService.createSupplier(dto);
        return Result.success(supplier);
    }

    @GetMapping("/{id}")
    public Result<Supplier> getSupplierById(@PathVariable Long id) {
        Supplier supplier = supplierService.getSupplierById(id);
        return Result.success(supplier);
    }

    @PutMapping("/{id}")
    public Result<Supplier> updateSupplier(@PathVariable Long id, @Validated @RequestBody SupplierDTO dto) {
        Supplier supplier = supplierService.updateSupplier(id, dto);
        return Result.success(supplier);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteSupplier(@PathVariable Long id) {
        supplierService.deleteSupplier(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<Supplier>> querySuppliers(SupplierQueryDTO queryDTO) {
        Page<Supplier> page = supplierService.querySuppliers(queryDTO);
        return Result.success(page);
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        supplierService.updateStatus(id, status);
        return Result.success();
    }
}
