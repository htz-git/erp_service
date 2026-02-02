package com.erplist.payment.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.payment.dto.PaymentDTO;
import com.erplist.payment.dto.PaymentQueryDTO;
import com.erplist.payment.entity.Payment;

/**
 * 支付记录服务接口
 */
public interface PaymentService {

    Payment createPayment(PaymentDTO dto);

    Payment getPaymentById(Long id);

    Payment updatePayment(Long id, PaymentDTO dto);

    void deletePayment(Long id);

    Page<Payment> queryPayments(PaymentQueryDTO queryDTO);
}
