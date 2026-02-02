package com.erplist.payment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.erplist.common.exception.BusinessException;
import com.erplist.payment.entity.PaymentMethod;
import com.erplist.payment.mapper.PaymentMethodMapper;
import com.erplist.payment.service.PaymentMethodService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 支付方式服务实现
 */
@Service
@RequiredArgsConstructor
public class PaymentMethodServiceImpl implements PaymentMethodService {

    private final PaymentMethodMapper paymentMethodMapper;

    @Override
    public List<PaymentMethod> listPaymentMethods() {
        LambdaQueryWrapper<PaymentMethod> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PaymentMethod::getStatus, 1);
        wrapper.orderByAsc(PaymentMethod::getSortOrder);
        return paymentMethodMapper.selectList(wrapper);
    }

    @Override
    public PaymentMethod getPaymentMethodById(Long id) {
        PaymentMethod method = paymentMethodMapper.selectById(id);
        if (method == null) {
            throw new BusinessException("支付方式不存在");
        }
        return method;
    }
}
