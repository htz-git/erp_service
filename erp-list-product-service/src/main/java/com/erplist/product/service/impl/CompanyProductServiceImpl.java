package com.erplist.product.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.product.dto.CompanyProductDTO;
import com.erplist.product.dto.CompanyProductQueryDTO;
import com.erplist.product.entity.CompanyProduct;
import com.erplist.product.mapper.CompanyProductMapper;
import com.erplist.product.service.CompanyProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 公司商品服务实现
 */
@Service
@RequiredArgsConstructor
public class CompanyProductServiceImpl implements CompanyProductService {

    private final CompanyProductMapper companyProductMapper;

    @Override
    public CompanyProduct create(CompanyProductDTO dto) {
        CompanyProduct entity = new CompanyProduct();
        BeanUtils.copyProperties(dto, entity, "id", "createTime", "updateTime");
        String zid = StringUtils.hasText(dto.getZid()) ? dto.getZid() : UserContext.getZid();
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        if (StringUtils.hasText(zid)) {
            entity.setZid(zid);
        }
        if (sid != null) {
            entity.setSid(sid);
        }
        companyProductMapper.insert(entity);
        return entity;
    }

    @Override
    public CompanyProduct getById(Long id) {
        CompanyProduct entity = companyProductMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("商品不存在");
        }
        return entity;
    }

    @Override
    public CompanyProduct update(Long id, CompanyProductDTO dto) {
        CompanyProduct entity = companyProductMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("商品不存在");
        }
        BeanUtils.copyProperties(dto, entity, "id", "createTime");
        if (StringUtils.hasText(dto.getZid())) {
            entity.setZid(dto.getZid());
        }
        if (dto.getSid() != null) {
            entity.setSid(dto.getSid());
        }
        companyProductMapper.updateById(entity);
        return entity;
    }

    @Override
    public void deleteById(Long id) {
        CompanyProduct entity = companyProductMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("商品不存在");
        }
        companyProductMapper.deleteById(id);
    }

    @Override
    public Page<CompanyProduct> query(CompanyProductQueryDTO queryDTO) {
        Page<CompanyProduct> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<CompanyProduct> wrapper = new LambdaQueryWrapper<>();
        String zid = StringUtils.hasText(queryDTO.getZid()) ? queryDTO.getZid() : UserContext.getZid();
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        if (StringUtils.hasText(zid)) {
            wrapper.eq(CompanyProduct::getZid, zid);
        }
        if (sid != null) {
            wrapper.eq(CompanyProduct::getSid, sid);
        }
        if (StringUtils.hasText(queryDTO.getProductName())) {
            wrapper.like(CompanyProduct::getProductName, queryDTO.getProductName());
        }
        if (StringUtils.hasText(queryDTO.getProductCode())) {
            wrapper.eq(CompanyProduct::getProductCode, queryDTO.getProductCode());
        }
        wrapper.orderByDesc(CompanyProduct::getCreateTime);
        return companyProductMapper.selectPage(page, wrapper);
    }
}
