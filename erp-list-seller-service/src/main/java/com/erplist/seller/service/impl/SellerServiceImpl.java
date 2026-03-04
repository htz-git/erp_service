package com.erplist.seller.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.api.client.UserClient;
import com.erplist.api.dto.AuditLogRecordDTO;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.result.Result;
import com.erplist.common.utils.UserContext;
import com.erplist.seller.dto.SellerDTO;
import com.erplist.seller.dto.SellerQueryDTO;
import com.erplist.seller.entity.Seller;
import com.erplist.seller.mapper.SellerMapper;
import com.erplist.seller.service.SellerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 店铺服务实现
 */
@Slf4j
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
        saveAuditLog("seller_create", "seller", String.valueOf(seller.getId()),
                "创建店铺: " + (StringUtils.hasText(seller.getSellerName()) ? seller.getSellerName() : "id=" + seller.getId()));
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
        saveAuditLog("seller_update", "seller", String.valueOf(id), "修改店铺: id=" + id);
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
        saveAuditLog("seller_delete", "seller", String.valueOf(id), "删除店铺: id=" + id);
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
        String actionType = status == 1 ? "seller_enable" : "seller_disable";
        saveAuditLog(actionType, "seller", String.valueOf(id), (status == 1 ? "启用" : "禁用") + "店铺: id=" + id);
    }

    @Override
    public long countByZid(String zid) {
        LambdaQueryWrapper<Seller> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(zid)) {
            wrapper.eq(Seller::getZid, zid);
        }
        return sellerMapper.selectCount(wrapper);
    }

    private void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该店铺");
        }
    }

    private void saveAuditLog(String actionType, String targetType, String targetId, String detail) {
        try {
            AuditLogRecordDTO dto = new AuditLogRecordDTO();
            dto.setOperatorId(UserContext.getUserId());
            dto.setOperatorName(null);
            dto.setActionType(actionType);
            dto.setTargetType(targetType);
            dto.setTargetId(targetId);
            dto.setDetail(detail);
            userClient.recordAuditLog(dto);
        } catch (Exception e) {
            log.warn("记录店铺审计日志失败: actionType={}, targetId={}", actionType, targetId, e);
        }
    }
}
