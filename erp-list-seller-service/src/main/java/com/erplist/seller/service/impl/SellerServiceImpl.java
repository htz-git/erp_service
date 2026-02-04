package com.erplist.seller.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.api.client.UserClient;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.result.Result;
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

    private static final String PERMISSION_SELLER_CREATE = "seller:create";
    private static final String PERMISSION_SELLER_DELETE = "seller:delete";

    private final SellerMapper sellerMapper;
    private final UserClient userClient;

    @Override
    public Seller createSeller(SellerDTO dto) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的店铺");
        }
        Long userId = UserContext.getUserId();
        if (userId != null) {
            Result<Boolean> res = userClient.hasPermission(userId, PERMISSION_SELLER_CREATE);
            if (res == null || res.getData() == null || !res.getData()) {
                throw new BusinessException(403, "无权限：需要店铺新增权限");
            }
        }
        Seller seller = new Seller();
        BeanUtils.copyProperties(dto, seller);
        Long sellerUserId = dto.getUserId() != null ? dto.getUserId() : UserContext.getUserId();
        if (sellerUserId != null) {
            seller.setUserId(sellerUserId);
        }
        seller.setZid(zid);
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
        ensureSameZid(seller.getZid());
        return seller;
    }

    @Override
    public Seller updateSeller(Long id, SellerDTO dto) {
        Seller seller = sellerMapper.selectById(id);
        if (seller == null) {
            throw new BusinessException("店铺不存在");
        }
        ensureSameZid(seller.getZid());
        BeanUtils.copyProperties(dto, seller, "id", "sid", "createTime");
        seller.setZid(UserContext.getZid());
        sellerMapper.updateById(seller);
        return seller;
    }

    @Override
    public void deleteSeller(Long id) {
        Seller seller = sellerMapper.selectById(id);
        if (seller == null) {
            throw new BusinessException("店铺不存在");
        }
        ensureSameZid(seller.getZid());
        Long userId = UserContext.getUserId();
        if (userId != null) {
            Result<Boolean> res = userClient.hasPermission(userId, PERMISSION_SELLER_DELETE);
            if (res == null || res.getData() == null || !res.getData()) {
                throw new BusinessException(403, "无权限：需要店铺删除权限");
            }
        }
        sellerMapper.deleteById(id);
    }

    @Override
    public Page<Seller> querySellers(SellerQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的店铺");
        }
        Page<Seller> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Seller> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Seller::getZid, zid);
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
        ensureSameZid(seller.getZid());
        if (status != 0 && status != 1) {
            throw new BusinessException("状态值不合法");
        }
        seller.setStatus(status);
        sellerMapper.updateById(seller);
    }

    private void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该店铺");
        }
    }
}
