package com.erplist.refund.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.refund.dto.RefundApplicationDTO;
import com.erplist.refund.dto.RefundApplicationQueryDTO;
import com.erplist.refund.entity.RefundApplication;
import com.erplist.refund.mapper.RefundApplicationMapper;
import com.erplist.refund.service.RefundApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.UUID;

/**
 * 退款申请服务实现（支持 zid/sid 多租户）
 */
@Service
@RequiredArgsConstructor
public class RefundApplicationServiceImpl implements RefundApplicationService {

    private final RefundApplicationMapper refundApplicationMapper;

    @Override
    public RefundApplication createRefundApplication(RefundApplicationDTO dto) {
        RefundApplication entity = new RefundApplication();
        BeanUtils.copyProperties(dto, entity);
        String zid = dto.getZid() != null ? dto.getZid() : UserContext.getZid();
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        entity.setZid(zid);
        entity.setSid(sid);
        if (!StringUtils.hasText(entity.getRefundNo())) {
            entity.setRefundNo("RF" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        entity.setRefundStatus(entity.getRefundStatus() != null ? entity.getRefundStatus() : 0);
        refundApplicationMapper.insert(entity);
        return entity;
    }

    @Override
    public RefundApplication getRefundApplicationById(Long id) {
        RefundApplication entity = refundApplicationMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("退款申请不存在");
        }
        return entity;
    }

    @Override
    public RefundApplication updateRefundApplication(Long id, RefundApplicationDTO dto) {
        RefundApplication entity = refundApplicationMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("退款申请不存在");
        }
        BeanUtils.copyProperties(dto, entity, "id", "refundNo", "createTime");
        refundApplicationMapper.updateById(entity);
        return entity;
    }

    @Override
    public void deleteRefundApplication(Long id) {
        RefundApplication entity = refundApplicationMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("退款申请不存在");
        }
        refundApplicationMapper.deleteById(id);
    }

    @Override
    public Page<RefundApplication> queryRefundApplications(RefundApplicationQueryDTO queryDTO) {
        Page<RefundApplication> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<RefundApplication> wrapper = new LambdaQueryWrapper<>();
        String zid = queryDTO.getZid() != null ? queryDTO.getZid() : UserContext.getZid();
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        if (StringUtils.hasText(zid)) {
            wrapper.eq(RefundApplication::getZid, zid);
        }
        if (sid != null) {
            wrapper.eq(RefundApplication::getSid, sid);
        }
        if (StringUtils.hasText(queryDTO.getRefundNo())) {
            wrapper.eq(RefundApplication::getRefundNo, queryDTO.getRefundNo());
        }
        if (queryDTO.getOrderId() != null) {
            wrapper.eq(RefundApplication::getOrderId, queryDTO.getOrderId());
        }
        if (StringUtils.hasText(queryDTO.getOrderNo())) {
            wrapper.eq(RefundApplication::getOrderNo, queryDTO.getOrderNo());
        }
        if (queryDTO.getUserId() != null) {
            wrapper.eq(RefundApplication::getUserId, queryDTO.getUserId());
        }
        if (queryDTO.getPaymentId() != null) {
            wrapper.eq(RefundApplication::getPaymentId, queryDTO.getPaymentId());
        }
        if (queryDTO.getRefundStatus() != null) {
            wrapper.eq(RefundApplication::getRefundStatus, queryDTO.getRefundStatus());
        }
        wrapper.orderByDesc(RefundApplication::getCreateTime);
        return refundApplicationMapper.selectPage(page, wrapper);
    }
}
