package com.erplist.product.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.api.client.UserClient;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.result.Result;
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

    private static final String PERMISSION_PRODUCT_CREATE = "product:create";

    private final CompanyProductMapper companyProductMapper;
    private final UserClient userClient;

    @Override
    public CompanyProduct create(CompanyProductDTO dto) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的商品");
        }
        Long userId = UserContext.getUserId();
        if (userId != null) {
            Result<Boolean> res = userClient.hasPermission(userId, PERMISSION_PRODUCT_CREATE);
            if (res == null || res.getData() == null || !res.getData()) {
                throw new BusinessException(403, "无权限：需要商品新增/上传权限");
            }
        }
        CompanyProduct entity = new CompanyProduct();
        BeanUtils.copyProperties(dto, entity, "id", "createTime", "updateTime");
        entity.setZid(zid);
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
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
        ensureSameZid(entity.getZid());
        return entity;
    }

    @Override
    public CompanyProduct update(Long id, CompanyProductDTO dto) {
        CompanyProduct entity = companyProductMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("商品不存在");
        }
        ensureSameZid(entity.getZid());
        BeanUtils.copyProperties(dto, entity, "id", "createTime");
        entity.setZid(UserContext.getZid());
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
        ensureSameZid(entity.getZid());
        companyProductMapper.deleteById(id);
    }

    @Override
    public Page<CompanyProduct> query(CompanyProductQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的商品");
        }
        Page<CompanyProduct> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<CompanyProduct> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CompanyProduct::getZid, zid);
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
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

    private void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该商品");
        }
    }
}
