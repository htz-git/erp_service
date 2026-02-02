package com.erplist.payment.service;

import com.erplist.payment.entity.PaymentMethod;

import java.util.List;

/**
 * 支付方式服务接口
 */
public interface PaymentMethodService {

    List<PaymentMethod> listPaymentMethods();

    PaymentMethod getPaymentMethodById(Long id);
}
