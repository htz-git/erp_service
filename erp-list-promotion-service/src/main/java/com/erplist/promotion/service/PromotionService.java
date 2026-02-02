package com.erplist.promotion.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.promotion.dto.PromotionDTO;
import com.erplist.promotion.dto.PromotionQueryDTO;
import com.erplist.promotion.entity.Promotion;

/**
 * 促销活动服务接口
 */
public interface PromotionService {
    Promotion createPromotion(PromotionDTO dto);
    Promotion getPromotionById(Long id);
    Promotion updatePromotion(Long id, PromotionDTO dto);
    void deletePromotion(Long id);
    Page<Promotion> queryPromotions(PromotionQueryDTO queryDTO);
    void updateStatus(Long id, Integer status);
}
