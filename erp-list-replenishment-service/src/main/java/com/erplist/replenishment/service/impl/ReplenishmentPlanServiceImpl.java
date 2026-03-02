package com.erplist.replenishment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.replenishment.dto.ReplenishmentPlanDTO;
import com.erplist.replenishment.dto.ReplenishmentPlanQueryDTO;
import com.erplist.replenishment.entity.ReplenishmentPlan;
import com.erplist.replenishment.mapper.ReplenishmentPlanMapper;
import com.erplist.replenishment.service.ReplenishmentPlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class ReplenishmentPlanServiceImpl implements ReplenishmentPlanService {

    private final ReplenishmentPlanMapper replenishmentPlanMapper;

    @Override
    public Page<ReplenishmentPlan> query(ReplenishmentPlanQueryDTO queryDTO) {
        Page<ReplenishmentPlan> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<ReplenishmentPlan> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(queryDTO.getPlanName())) {
            wrapper.like(ReplenishmentPlan::getPlanName, queryDTO.getPlanName());
        }
        if (queryDTO.getProductId() != null) {
            wrapper.eq(ReplenishmentPlan::getProductId, queryDTO.getProductId());
        }
        if (queryDTO.getSkuId() != null) {
            wrapper.eq(ReplenishmentPlan::getSkuId, queryDTO.getSkuId());
        }
        if (queryDTO.getPlanStatus() != null) {
            wrapper.eq(ReplenishmentPlan::getPlanStatus, queryDTO.getPlanStatus());
        }
        wrapper.orderByDesc(ReplenishmentPlan::getUpdateTime);
        return replenishmentPlanMapper.selectPage(page, wrapper);
    }

    @Override
    public ReplenishmentPlan getById(Long id) {
        ReplenishmentPlan entity = replenishmentPlanMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("补货计划不存在");
        }
        return entity;
    }

    @Override
    public ReplenishmentPlan create(ReplenishmentPlanDTO dto) {
        if (!StringUtils.hasText(dto.getPlanName())) {
            throw new BusinessException("计划名称不能为空");
        }
        if (dto.getProductId() == null) {
            throw new BusinessException("商品ID不能为空");
        }
        ReplenishmentPlan entity = new ReplenishmentPlan();
        BeanUtils.copyProperties(dto, entity, "id");
        entity.setProductName(dto.getProductName() != null ? dto.getProductName() : "");
        entity.setMinStock(dto.getMinStock() != null ? dto.getMinStock() : 0);
        entity.setMaxStock(dto.getMaxStock() != null ? dto.getMaxStock() : 0);
        entity.setReorderPoint(dto.getReorderPoint() != null ? dto.getReorderPoint() : 0);
        entity.setReorderQuantity(dto.getReorderQuantity() != null ? dto.getReorderQuantity() : 0);
        entity.setPlanStatus(dto.getPlanStatus() != null ? dto.getPlanStatus() : 1);
        entity.setDeleted(0);
        replenishmentPlanMapper.insert(entity);
        return entity;
    }

    @Override
    public ReplenishmentPlan update(Long id, ReplenishmentPlanDTO dto) {
        ReplenishmentPlan existing = replenishmentPlanMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("补货计划不存在");
        }
        if (StringUtils.hasText(dto.getPlanName())) {
            existing.setPlanName(dto.getPlanName());
        }
        if (dto.getProductId() != null) {
            existing.setProductId(dto.getProductId());
        }
        if (StringUtils.hasText(dto.getProductName())) {
            existing.setProductName(dto.getProductName());
        }
        if (dto.getSkuId() != null) {
            existing.setSkuId(dto.getSkuId());
        }
        if (dto.getWarehouseId() != null) {
            existing.setWarehouseId(dto.getWarehouseId());
        }
        if (dto.getMinStock() != null) {
            existing.setMinStock(dto.getMinStock());
        }
        if (dto.getMaxStock() != null) {
            existing.setMaxStock(dto.getMaxStock());
        }
        if (dto.getReorderPoint() != null) {
            existing.setReorderPoint(dto.getReorderPoint());
        }
        if (dto.getReorderQuantity() != null) {
            existing.setReorderQuantity(dto.getReorderQuantity());
        }
        if (dto.getPlanStatus() != null) {
            existing.setPlanStatus(dto.getPlanStatus());
        }
        if (dto.getNextReplenishmentTime() != null) {
            existing.setNextReplenishmentTime(dto.getNextReplenishmentTime());
        }
        replenishmentPlanMapper.updateById(existing);
        return existing;
    }

    @Override
    public void deleteById(Long id) {
        ReplenishmentPlan existing = replenishmentPlanMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("补货计划不存在");
        }
        replenishmentPlanMapper.deleteById(id);
    }
}
