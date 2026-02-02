package com.erplist.promotion.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.promotion.dto.PromotionDTO;
import com.erplist.promotion.dto.PromotionQueryDTO;
import com.erplist.promotion.entity.Promotion;
import com.erplist.promotion.mapper.PromotionMapper;
import com.erplist.promotion.service.PromotionService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 促销活动服务实现
 */
@Service
@RequiredArgsConstructor
public class PromotionServiceImpl implements PromotionService {

    private final PromotionMapper promotionMapper;

    @Override
    public Promotion createPromotion(PromotionDTO dto) {
        Promotion promotion = new Promotion();
        BeanUtils.copyProperties(dto, promotion);
        promotion.setStatus(promotion.getStatus() != null ? promotion.getStatus() : 1);
        promotionMapper.insert(promotion);
        return promotion;
    }

    @Override
    public Promotion getPromotionById(Long id) {
        Promotion promotion = promotionMapper.selectById(id);
        if (promotion == null) {
            throw new BusinessException("促销活动不存在");
        }
        return promotion;
    }

    @Override
    public Promotion updatePromotion(Long id, PromotionDTO dto) {
        Promotion promotion = promotionMapper.selectById(id);
        if (promotion == null) {
            throw new BusinessException("促销活动不存在");
        }
        BeanUtils.copyProperties(dto, promotion, "id", "createTime");
        promotionMapper.updateById(promotion);
        return promotion;
    }

    @Override
    public void deletePromotion(Long id) {
        Promotion promotion = promotionMapper.selectById(id);
        if (promotion == null) {
            throw new BusinessException("促销活动不存在");
        }
        promotionMapper.deleteById(id);
    }

    @Override
    public Page<Promotion> queryPromotions(PromotionQueryDTO queryDTO) {
        Page<Promotion> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Promotion> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(queryDTO.getPromotionName())) {
            wrapper.like(Promotion::getPromotionName, queryDTO.getPromotionName());
        }
        if (StringUtils.hasText(queryDTO.getPromotionType())) {
            wrapper.eq(Promotion::getPromotionType, queryDTO.getPromotionType());
        }
        if (queryDTO.getStatus() != null) {
            wrapper.eq(Promotion::getStatus, queryDTO.getStatus());
        }
        wrapper.orderByDesc(Promotion::getCreateTime);
        return promotionMapper.selectPage(page, wrapper);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        Promotion promotion = promotionMapper.selectById(id);
        if (promotion == null) {
            throw new BusinessException("促销活动不存在");
        }
        if (status != 0 && status != 1) {
            throw new BusinessException("状态值不合法");
        }
        promotion.setStatus(status);
        promotionMapper.updateById(promotion);
    }
}
