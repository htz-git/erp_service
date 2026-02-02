package com.erplist.purchase.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.purchase.dto.SupplierDTO;
import com.erplist.purchase.dto.SupplierQueryDTO;
import com.erplist.purchase.entity.Supplier;
import com.erplist.purchase.mapper.SupplierMapper;
import com.erplist.purchase.service.SupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 供应商服务实现
 */
@Service
@RequiredArgsConstructor
public class SupplierServiceImpl implements SupplierService {

    private final SupplierMapper supplierMapper;

    @Override
    public Supplier createSupplier(SupplierDTO dto) {
        Supplier supplier = new Supplier();
        BeanUtils.copyProperties(dto, supplier);
        supplier.setStatus(supplier.getStatus() != null ? supplier.getStatus() : 1);
        supplierMapper.insert(supplier);
        return supplier;
    }

    @Override
    public Supplier getSupplierById(Long id) {
        Supplier supplier = supplierMapper.selectById(id);
        if (supplier == null) {
            throw new BusinessException("供应商不存在");
        }
        return supplier;
    }

    @Override
    public Supplier updateSupplier(Long id, SupplierDTO dto) {
        Supplier supplier = supplierMapper.selectById(id);
        if (supplier == null) {
            throw new BusinessException("供应商不存在");
        }
        BeanUtils.copyProperties(dto, supplier, "id", "createTime");
        supplierMapper.updateById(supplier);
        return supplier;
    }

    @Override
    public void deleteSupplier(Long id) {
        Supplier supplier = supplierMapper.selectById(id);
        if (supplier == null) {
            throw new BusinessException("供应商不存在");
        }
        supplierMapper.deleteById(id);
    }

    @Override
    public Page<Supplier> querySuppliers(SupplierQueryDTO queryDTO) {
        Page<Supplier> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Supplier> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(queryDTO.getSupplierName())) {
            wrapper.like(Supplier::getSupplierName, queryDTO.getSupplierName());
        }
        if (StringUtils.hasText(queryDTO.getSupplierCode())) {
            wrapper.eq(Supplier::getSupplierCode, queryDTO.getSupplierCode());
        }
        if (queryDTO.getStatus() != null) {
            wrapper.eq(Supplier::getStatus, queryDTO.getStatus());
        }
        wrapper.orderByDesc(Supplier::getCreateTime);
        return supplierMapper.selectPage(page, wrapper);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        Supplier supplier = supplierMapper.selectById(id);
        if (supplier == null) {
            throw new BusinessException("供应商不存在");
        }
        if (status != 0 && status != 1) {
            throw new BusinessException("状态值不合法");
        }
        supplier.setStatus(status);
        supplierMapper.updateById(supplier);
    }
}
