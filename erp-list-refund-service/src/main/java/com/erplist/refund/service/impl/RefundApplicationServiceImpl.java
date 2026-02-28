package com.erplist.refund.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.api.client.OrderClient;
import com.erplist.api.dto.OrderItemImageDTO;
import com.erplist.refund.dto.RefundApplicationDTO;
import com.erplist.refund.dto.RefundApplicationQueryDTO;
import com.erplist.refund.dto.RefundListVO;
import com.erplist.refund.entity.RefundApplication;
import com.erplist.refund.mapper.RefundApplicationMapper;
import com.erplist.refund.service.RefundApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import com.erplist.common.result.Result;

/**
 * 退款申请服务实现（支持 zid/sid 多租户）
 */
@Service
@RequiredArgsConstructor
public class RefundApplicationServiceImpl implements RefundApplicationService {

    private final RefundApplicationMapper refundApplicationMapper;
    private final OrderClient orderClient;

    @Override
    public RefundApplication createRefundApplication(RefundApplicationDTO dto) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的退款申请");
        }
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        if (dto.getOrderItemId() != null) {
            LambdaQueryWrapper<RefundApplication> existWrapper = new LambdaQueryWrapper<>();
            existWrapper.eq(RefundApplication::getOrderId, dto.getOrderId())
                .eq(RefundApplication::getOrderItemId, dto.getOrderItemId());
            if (refundApplicationMapper.selectCount(existWrapper) > 0) {
                throw new BusinessException("该订单该商品已存在退款申请");
            }
        }
        RefundApplication entity = new RefundApplication();
        BeanUtils.copyProperties(dto, entity);
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
        ensureSameZid(entity.getZid());
        return entity;
    }

    @Override
    public RefundApplication updateRefundApplication(Long id, RefundApplicationDTO dto) {
        RefundApplication entity = refundApplicationMapper.selectById(id);
        if (entity == null) {
            throw new BusinessException("退款申请不存在");
        }
        ensureSameZid(entity.getZid());
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
        ensureSameZid(entity.getZid());
        refundApplicationMapper.deleteById(id);
    }

    @Override
    public Page<RefundListVO> queryRefundApplications(RefundApplicationQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的退款申请");
        }
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        Page<RefundApplication> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<RefundApplication> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(RefundApplication::getZid, zid);
        if (sid != null) {
            wrapper.eq(RefundApplication::getSid, sid);
        }
        if (StringUtils.hasText(queryDTO.getRefundNo())) {
            wrapper.eq(RefundApplication::getRefundNo, queryDTO.getRefundNo());
        }
        if (queryDTO.getOrderId() != null) {
            wrapper.eq(RefundApplication::getOrderId, queryDTO.getOrderId());
        }
        if (queryDTO.getOrderItemId() != null) {
            wrapper.eq(RefundApplication::getOrderItemId, queryDTO.getOrderItemId());
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
        Page<RefundApplication> appPage = refundApplicationMapper.selectPage(page, wrapper);
        List<RefundApplication> records = appPage.getRecords();
        List<RefundListVO> voList = new ArrayList<>();
        if (records != null && !records.isEmpty()) {
            List<Long> orderItemIds = records.stream()
                .map(RefundApplication::getOrderItemId)
                .filter(id -> id != null)
                .distinct()
                .collect(Collectors.toList());
            Map<Long, String> itemIdToImage = Collections.emptyMap();
            if (!orderItemIds.isEmpty()) {
                try {
                    Result<List<OrderItemImageDTO>> res = orderClient.getOrderItemProductImages(orderItemIds);
                    if (res != null && res.getData() != null) {
                        itemIdToImage = res.getData().stream()
                            .filter(dto -> dto.getOrderItemId() != null && dto.getProductImage() != null)
                            .collect(Collectors.toMap(OrderItemImageDTO::getOrderItemId, OrderItemImageDTO::getProductImage, (a, b) -> a));
                    }
                } catch (Exception ignored) {
                    // 订单服务不可用时仅不展示图片
                }
            }
            Map<Long, String> finalItemIdToImage = itemIdToImage;
            for (RefundApplication ra : records) {
                RefundListVO vo = new RefundListVO();
                BeanUtils.copyProperties(ra, vo);
                vo.setProductImageUrl(ra.getOrderItemId() != null ? finalItemIdToImage.get(ra.getOrderItemId()) : null);
                voList.add(vo);
            }
        }
        Page<RefundListVO> voPage = new Page<>(appPage.getCurrent(), appPage.getSize(), appPage.getTotal());
        voPage.setRecords(voList);
        return voPage;
    }

    /** 已退款状态：1=已通过/已退款 */
    private static final int REFUND_STATUS_REFUNDED = 1;

    @Override
    public List<Long> getOrderIdsWithRefund(List<Long> orderIds) {
        if (CollectionUtils.isEmpty(orderIds)) {
            return Collections.emptyList();
        }
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            return Collections.emptyList();
        }
        LambdaQueryWrapper<RefundApplication> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(RefundApplication::getZid, zid)
            .in(RefundApplication::getOrderId, orderIds)
            .eq(RefundApplication::getRefundStatus, REFUND_STATUS_REFUNDED)
            .select(RefundApplication::getOrderId);
        List<RefundApplication> list = refundApplicationMapper.selectList(wrapper);
        if (list == null || list.isEmpty()) {
            return Collections.emptyList();
        }
        return list.stream().map(RefundApplication::getOrderId).distinct().collect(Collectors.toList());
    }

    private void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该退款申请");
        }
    }
}
