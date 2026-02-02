package com.erplist.promotion.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.promotion.dto.PromotionDTO;
import com.erplist.promotion.dto.PromotionQueryDTO;
import com.erplist.promotion.entity.Promotion;
import com.erplist.promotion.service.PromotionService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 促销活动控制器
 */
@RestController
@RequestMapping("/promotions")
@RequiredArgsConstructor
public class PromotionController {

    private final PromotionService promotionService;

    @PostMapping
    public Result<Promotion> createPromotion(@Validated @RequestBody PromotionDTO dto) {
        Promotion promotion = promotionService.createPromotion(dto);
        return Result.success(promotion);
    }

    @GetMapping("/{id}")
    public Result<Promotion> getPromotionById(@PathVariable Long id) {
        Promotion promotion = promotionService.getPromotionById(id);
        return Result.success(promotion);
    }

    @PutMapping("/{id}")
    public Result<Promotion> updatePromotion(@PathVariable Long id, @Validated @RequestBody PromotionDTO dto) {
        Promotion promotion = promotionService.updatePromotion(id, dto);
        return Result.success(promotion);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deletePromotion(@PathVariable Long id) {
        promotionService.deletePromotion(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<Promotion>> queryPromotions(PromotionQueryDTO queryDTO) {
        Page<Promotion> page = promotionService.queryPromotions(queryDTO);
        return Result.success(page);
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        promotionService.updateStatus(id, status);
        return Result.success();
    }
}
