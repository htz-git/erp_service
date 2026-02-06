package com.erplist.replenishment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.replenishment.dto.InventoryDTO;
import com.erplist.replenishment.dto.InventoryQueryDTO;
import com.erplist.replenishment.entity.Inventory;
import com.erplist.replenishment.mapper.InventoryMapper;
import com.erplist.replenishment.service.InventoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 库存服务实现（按公司 zid 隔离）
 */
@Service
@RequiredArgsConstructor
public class InventoryServiceImpl implements InventoryService {

    private final InventoryMapper inventoryMapper;

    @Override
    public Inventory create(InventoryDTO dto) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的库存");
        }
        Long skuId = dto.getSkuId() != null ? dto.getSkuId() : dto.getProductId();
        if (skuId == null) {
            throw new BusinessException("商品ID与SKU ID不能同时为空");
        }
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Inventory::getZid, zid).eq(Inventory::getSkuId, skuId);
        if (inventoryMapper.selectCount(wrapper) > 0) {
            throw new BusinessException("该公司下该SKU已存在库存记录，请勿重复创建");
        }
        Inventory entity = new Inventory();
        BeanUtils.copyProperties(dto, entity, "id");
        entity.setZid(zid);
        entity.setSkuId(skuId);
        entity.setCurrentStock(dto.getCurrentStock() != null ? dto.getCurrentStock() : 0);
        entity.setMinStock(dto.getMinStock() != null ? dto.getMinStock() : 0);
        inventoryMapper.insert(entity);
        return entity;
    }

    @Override
    public Inventory update(Long id, InventoryDTO dto) {
        Inventory existing = inventoryMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException("库存记录不存在");
        }
        ensureSameZid(existing.getZid());
        if (dto.getCurrentStock() != null) {
            existing.setCurrentStock(dto.getCurrentStock());
        }
        if (dto.getMinStock() != null) {
            existing.setMinStock(dto.getMinStock());
        }
        if (StringUtils.hasText(dto.getProductName())) {
            existing.setProductName(dto.getProductName());
        }
        if (StringUtils.hasText(dto.getSkuCode())) {
            existing.setSkuCode(dto.getSkuCode());
        }
        inventoryMapper.updateById(existing);
        return existing;
    }

    @Override
    public Inventory getById(Long id) {
        Inventory entity = inventoryMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("库存记录不存在");
        }
        ensureSameZid(entity.getZid());
        return entity;
    }

    @Override
    public Page<Inventory> query(InventoryQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的库存");
        }
        Page<Inventory> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Inventory::getZid, zid);
        if (StringUtils.hasText(queryDTO.getSkuCode())) {
            wrapper.eq(Inventory::getSkuCode, queryDTO.getSkuCode());
        }
        if (StringUtils.hasText(queryDTO.getKeyword())) {
            wrapper.and(w -> w.like(Inventory::getSkuCode, queryDTO.getKeyword())
                    .or().like(Inventory::getProductName, queryDTO.getKeyword()));
        }
        wrapper.orderByDesc(Inventory::getUpdateTime);
        return inventoryMapper.selectPage(page, wrapper);
    }

    private static void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该库存记录");
        }
    }
}
