package com.erplist.promotion.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.promotion.dto.CouponDTO;
import com.erplist.promotion.dto.CouponQueryDTO;
import com.erplist.promotion.entity.Coupon;

/**
 * 优惠券服务接口
 */
public interface CouponService {
    Coupon createCoupon(CouponDTO dto);
    Coupon getCouponById(Long id);
    Coupon updateCoupon(Long id, CouponDTO dto);
    void deleteCoupon(Long id);
    Page<Coupon> queryCoupons(CouponQueryDTO queryDTO);
    void updateStatus(Long id, Integer status);
}
