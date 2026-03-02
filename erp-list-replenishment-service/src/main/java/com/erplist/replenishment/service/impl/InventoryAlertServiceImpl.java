package com.erplist.replenishment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.replenishment.dto.InventoryAlertHandleDTO;
import com.erplist.replenishment.dto.InventoryAlertQueryDTO;
import com.erplist.replenishment.entity.InventoryAlert;
import com.erplist.replenishment.mapper.InventoryAlertMapper;
import com.erplist.replenishment.service.InventoryAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class InventoryAlertServiceImpl implements InventoryAlertService {

    private final InventoryAlertMapper inventoryAlertMapper;

    @Override
    public Page<InventoryAlert> query(InventoryAlertQueryDTO queryDTO) {
        Page<InventoryAlert> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<InventoryAlert> wrapper = new LambdaQueryWrapper<>();
        if (queryDTO.getAlertLevel() != null) {
            wrapper.eq(InventoryAlert::getAlertLevel, queryDTO.getAlertLevel());
        }
        if (queryDTO.getAlertStatus() != null) {
            wrapper.eq(InventoryAlert::getAlertStatus, queryDTO.getAlertStatus());
        }
        if (queryDTO.getProductId() != null) {
            wrapper.eq(InventoryAlert::getProductId, queryDTO.getProductId());
        }
        if (queryDTO.getSkuId() != null) {
            wrapper.eq(InventoryAlert::getSkuId, queryDTO.getSkuId());
        }
        wrapper.orderByDesc(InventoryAlert::getCreateTime);
        return inventoryAlertMapper.selectPage(page, wrapper);
    }

    @Override
    public InventoryAlert getById(Long id) {
        InventoryAlert entity = inventoryAlertMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("库存预警记录不存在");
        }
        return entity;
    }

    @Override
    public void markHandled(Long id, InventoryAlertHandleDTO dto) {
        InventoryAlert entity = inventoryAlertMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("库存预警记录不存在");
        }
        entity.setAlertStatus(1);
        entity.setHandleTime(LocalDateTime.now());
        if (dto != null && dto.getHandlerId() != null) {
            entity.setHandlerId(dto.getHandlerId());
        } else if (UserContext.getUserId() != null) {
            entity.setHandlerId(UserContext.getUserId());
        }
        if (dto != null && StringUtils.hasText(dto.getHandlerName())) {
            entity.setHandlerName(dto.getHandlerName());
        }
        inventoryAlertMapper.updateById(entity);
    }
}
