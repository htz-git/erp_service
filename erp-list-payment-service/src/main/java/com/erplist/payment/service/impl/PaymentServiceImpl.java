package com.erplist.payment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.payment.dto.PaymentDTO;
import com.erplist.payment.dto.PaymentQueryDTO;
import com.erplist.payment.entity.Payment;
import com.erplist.payment.mapper.PaymentMapper;
import com.erplist.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 支付记录服务实现
 */
@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final PaymentMapper paymentMapper;

    @Override
    public Payment createPayment(PaymentDTO dto) {
        Payment payment = new Payment();
        BeanUtils.copyProperties(dto, payment);
        String zid = dto.getZid() != null ? dto.getZid() : UserContext.getZid();
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        if (zid != null) payment.setZid(zid);
        if (sid != null) payment.setSid(sid);
        payment.setPaymentStatus(payment.getPaymentStatus() != null ? payment.getPaymentStatus() : 0);
        paymentMapper.insert(payment);
        return payment;
    }

    @Override
    public Payment getPaymentById(Long id) {
        Payment payment = paymentMapper.selectById(id);
        if (payment == null) {
            throw new BusinessException("支付记录不存在");
        }
        return payment;
    }

    @Override
    public Payment updatePayment(Long id, PaymentDTO dto) {
        Payment payment = paymentMapper.selectById(id);
        if (payment == null) {
            throw new BusinessException("支付记录不存在");
        }
        BeanUtils.copyProperties(dto, payment, "id", "createTime");
        paymentMapper.updateById(payment);
        return payment;
    }

    @Override
    public void deletePayment(Long id) {
        Payment payment = paymentMapper.selectById(id);
        if (payment == null) {
            throw new BusinessException("支付记录不存在");
        }
        paymentMapper.deleteById(id);
    }

    @Override
    public Page<Payment> queryPayments(PaymentQueryDTO queryDTO) {
        Page<Payment> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<Payment> wrapper = new LambdaQueryWrapper<>();
        String zid = queryDTO.getZid() != null ? queryDTO.getZid() : UserContext.getZid();
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        if (StringUtils.hasText(zid)) {
            wrapper.eq(Payment::getZid, zid);
        }
        if (sid != null) {
            wrapper.eq(Payment::getSid, sid);
        }
        if (StringUtils.hasText(queryDTO.getPaymentNo())) {
            wrapper.eq(Payment::getPaymentNo, queryDTO.getPaymentNo());
        }
        if (queryDTO.getOrderId() != null) {
            wrapper.eq(Payment::getOrderId, queryDTO.getOrderId());
        }
        if (StringUtils.hasText(queryDTO.getOrderNo())) {
            wrapper.eq(Payment::getOrderNo, queryDTO.getOrderNo());
        }
        if (queryDTO.getUserId() != null) {
            wrapper.eq(Payment::getUserId, queryDTO.getUserId());
        }
        if (queryDTO.getPaymentStatus() != null) {
            wrapper.eq(Payment::getPaymentStatus, queryDTO.getPaymentStatus());
        }
        wrapper.orderByDesc(Payment::getCreateTime);
        return paymentMapper.selectPage(page, wrapper);
    }
}
