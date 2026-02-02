package com.erplist.seller.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.seller.dto.SellerDTO;
import com.erplist.seller.dto.SellerQueryDTO;
import com.erplist.seller.entity.Seller;
import com.erplist.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 店铺控制器
 */
@RestController
@RequestMapping("/sellers")
@RequiredArgsConstructor
public class SellerController {

    private final SellerService sellerService;

    @PostMapping
    public Result<Seller> createSeller(@Validated @RequestBody SellerDTO dto) {
        Seller seller = sellerService.createSeller(dto);
        return Result.success(seller);
    }

    @GetMapping("/{id}")
    public Result<Seller> getSellerById(@PathVariable Long id) {
        Seller seller = sellerService.getSellerById(id);
        return Result.success(seller);
    }

    @PutMapping("/{id}")
    public Result<Seller> updateSeller(@PathVariable Long id, @Validated @RequestBody SellerDTO dto) {
        Seller seller = sellerService.updateSeller(id, dto);
        return Result.success(seller);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteSeller(@PathVariable Long id) {
        sellerService.deleteSeller(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<Seller>> querySellers(SellerQueryDTO queryDTO) {
        Page<Seller> page = sellerService.querySellers(queryDTO);
        return Result.success(page);
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        sellerService.updateStatus(id, status);
        return Result.success();
    }
}
