package com.erplist.promotion.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.promotion.dto.CouponDTO;
import com.erplist.promotion.dto.CouponQueryDTO;
import com.erplist.promotion.entity.Coupon;
import com.erplist.promotion.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 优惠券控制器
 */
@RestController
@RequestMapping("/coupons")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;

    @PostMapping
    public Result<Coupon> createCoupon(@Validated @RequestBody CouponDTO dto) {
        Coupon coupon = couponService.createCoupon(dto);
        return Result.success(coupon);
    }

    @GetMapping("/{id}")
    public Result<Coupon> getCouponById(@PathVariable Long id) {
        Coupon coupon = couponService.getCouponById(id);
        return Result.success(coupon);
    }

    @PutMapping("/{id}")
    public Result<Coupon> updateCoupon(@PathVariable Long id, @Validated @RequestBody CouponDTO dto) {
        Coupon coupon = couponService.updateCoupon(id, dto);
        return Result.success(coupon);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteCoupon(@PathVariable Long id) {
        couponService.deleteCoupon(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<Coupon>> queryCoupons(CouponQueryDTO queryDTO) {
        Page<Coupon> page = couponService.queryCoupons(queryDTO);
        return Result.success(page);
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        couponService.updateStatus(id, status);
        return Result.success();
    }
}
