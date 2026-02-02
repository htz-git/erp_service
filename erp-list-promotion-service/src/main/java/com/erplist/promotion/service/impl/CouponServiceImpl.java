package com.erplist.promotion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.promotion.dto.CouponDTO;
import com.erplist.promotion.dto.CouponQueryDTO;
import com.erplist.promotion.entity.Coupon;
import com.erplist.promotion.mapper.CouponMapper;
import com.erplist.promotion.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 优惠券服务实现
 */
@Service
@RequiredArgsConstructor
public class CouponServiceImpl implements CouponService {

    private final CouponMapper couponMapper;

    @Override
    public Coupon createCoupon(CouponDTO dto) {
        Coupon coupon = new Coupon();
        BeanUtils.copyProperties(dto, coupon);
        coupon.setUsedCount(0);
        coupon.setTotalCount(coupon.getTotalCount() != null ? coupon.getTotalCount() : 0);
        coupon.setMinAmount(coupon.getMinAmount() != null ? coupon.getMinAmount() : java.math.BigDecimal.ZERO);
        coupon.setStatus(coupon.getStatus() != null ? coupon.getStatus() : 1);
        couponMapper.insert(coupon);
        return coupon;
    }

    @Override
    public Coupon getCouponById(Long id) {
        Coupon coupon = couponMapper.selectById(id);
        if (coupon == null) {
            throw new BusinessException("优惠券不存在");
        }
        return coupon;
    }

    @Override
    public Coupon updateCoupon(Long id, CouponDTO dto) {
        Coupon coupon = couponMapper.selectById(id);
        if (coupon == null) {
            throw new BusinessException("优惠券不存在");
        }
        BeanUtils.copyProperties(dto, coupon, "id", "usedCount", "createTime");
        couponMapper.updateById(coupon);
        return coupon;
    }

    @Override
    public void deleteCoupon(Long id) {
        Coupon coupon = couponMapper.selectById(id);
        if (coupon == null) {
            throw new BusinessException("优惠券不存在");
        }
        couponMapper.deleteById(id);
    }

    @Override
    public Page<Coupon> queryCoupons(CouponQueryDTO queryDTO) {
        Page<Coupon> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Coupon> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(queryDTO.getCouponName())) {
            wrapper.like(Coupon::getCouponName, queryDTO.getCouponName());
        }
        if (StringUtils.hasText(queryDTO.getCouponType())) {
            wrapper.eq(Coupon::getCouponType, queryDTO.getCouponType());
        }
        if (queryDTO.getStatus() != null) {
            wrapper.eq(Coupon::getStatus, queryDTO.getStatus());
        }
        wrapper.orderByDesc(Coupon::getCreateTime);
        return couponMapper.selectPage(page, wrapper);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        Coupon coupon = couponMapper.selectById(id);
        if (coupon == null) {
            throw new BusinessException("优惠券不存在");
        }
        if (status != 0 && status != 1) {
            throw new BusinessException("状态值不合法");
        }
        coupon.setStatus(status);
        couponMapper.updateById(coupon);
    }
}
