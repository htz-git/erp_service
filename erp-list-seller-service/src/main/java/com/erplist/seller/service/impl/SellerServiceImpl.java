package com.erplist.seller.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.seller.dto.SellerDTO;
import com.erplist.seller.dto.SellerQueryDTO;
import com.erplist.seller.entity.Seller;
import com.erplist.seller.mapper.SellerMapper;
import com.erplist.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 店铺服务实现
 */
@Service
@RequiredArgsConstructor
public class SellerServiceImpl implements SellerService {

    private final SellerMapper sellerMapper;

    @Override
    public Seller createSeller(SellerDTO dto) {
        Seller seller = new Seller();
        BeanUtils.copyProperties(dto, seller);
        Long userId = dto.getUserId() != null ? dto.getUserId() : UserContext.getUserId();
        if (userId != null) {
            seller.setUserId(userId);
        }
        String zid = StringUtils.hasText(dto.getZid()) ? dto.getZid() : UserContext.getZid();
        if (zid != null) {
            seller.setZid(zid);
        }
        seller.setSid(null); // 插入后由 id 填充
        seller.setStatus(seller.getStatus() != null ? seller.getStatus() : 1);
        sellerMapper.insert(seller);
        seller.setSid(String.valueOf(seller.getId()));
        sellerMapper.updateById(seller);
        return seller;
    }

    @Override
    public Seller getSellerById(Long id) {
        Seller seller = sellerMapper.selectById(id);
        if (seller == null) {
            throw new BusinessException("店铺不存在");
        }
        return seller;
    }

    @Override
    public Seller updateSeller(Long id, SellerDTO dto) {
        Seller seller = sellerMapper.selectById(id);
        if (seller == null) {
            throw new BusinessException("店铺不存在");
        }
        BeanUtils.copyProperties(dto, seller, "id", "sid", "createTime");
        if (StringUtils.hasText(dto.getZid())) {
            seller.setZid(dto.getZid());
        }
        sellerMapper.updateById(seller);
        return seller;
    }

    @Override
    public void deleteSeller(Long id) {
        Seller seller = sellerMapper.selectById(id);
        if (seller == null) {
            throw new BusinessException("店铺不存在");
        }
        sellerMapper.deleteById(id);
    }

    @Override
    public Page<Seller> querySellers(SellerQueryDTO queryDTO) {
        Page<Seller> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Seller> wrapper = new LambdaQueryWrapper<>();
        String zid = StringUtils.hasText(queryDTO.getZid()) ? queryDTO.getZid() : UserContext.getZid();
        if (StringUtils.hasText(zid)) {
            wrapper.eq(Seller::getZid, zid);
        }
        Long userId = queryDTO.getUserId() != null ? queryDTO.getUserId() : UserContext.getUserId();
        if (userId != null) {
            wrapper.eq(Seller::getUserId, userId);
        }
        if (StringUtils.hasText(queryDTO.getSellerName())) {
            wrapper.like(Seller::getSellerName, queryDTO.getSellerName());
        }
        if (StringUtils.hasText(queryDTO.getPlatform())) {
            wrapper.eq(Seller::getPlatform, queryDTO.getPlatform());
        }
        if (queryDTO.getStatus() != null) {
            wrapper.eq(Seller::getStatus, queryDTO.getStatus());
        }
        wrapper.orderByDesc(Seller::getCreateTime);
        return sellerMapper.selectPage(page, wrapper);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        Seller seller = sellerMapper.selectById(id);
        if (seller == null) {
            throw new BusinessException("店铺不存在");
        }
        if (status != 0 && status != 1) {
            throw new BusinessException("状态值不合法");
        }
        seller.setStatus(status);
        sellerMapper.updateById(seller);
    }
}
