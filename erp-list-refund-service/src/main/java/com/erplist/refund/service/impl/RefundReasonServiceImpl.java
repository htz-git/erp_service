package com.erplist.refund.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.erplist.refund.entity.RefundReason;
import com.erplist.refund.mapper.RefundReasonMapper;
import com.erplist.refund.service.RefundReasonService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 退款原因服务实现
 */
@Service
@RequiredArgsConstructor
public class RefundReasonServiceImpl implements RefundReasonService {

    private final RefundReasonMapper refundReasonMapper;

    @Override
    public List<RefundReason> listRefundReasons(Integer status) {
        LambdaQueryWrapper<RefundReason> wrapper = new LambdaQueryWrapper<>();
        if (status != null) {
            wrapper.eq(RefundReason::getStatus, status);
        }
        wrapper.orderByAsc(RefundReason::getSortOrder);
        return refundReasonMapper.selectList(wrapper);
    }
}
