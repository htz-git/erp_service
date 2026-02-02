package com.erplist.payment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.payment.dto.PaymentDTO;
import com.erplist.payment.dto.PaymentQueryDTO;
import com.erplist.payment.entity.Payment;
import com.erplist.payment.entity.PaymentMethod;
import com.erplist.payment.service.PaymentMethodService;
import com.erplist.payment.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 支付控制器
 */
@RestController
@RequestMapping("/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;
    private final PaymentMethodService paymentMethodService;

    @PostMapping
    public Result<Payment> createPayment(@Validated @RequestBody PaymentDTO dto) {
        Payment payment = paymentService.createPayment(dto);
        return Result.success(payment);
    }

    @GetMapping("/{id}")
    public Result<Payment> getPaymentById(@PathVariable Long id) {
        Payment payment = paymentService.getPaymentById(id);
        return Result.success(payment);
    }

    @PutMapping("/{id}")
    public Result<Payment> updatePayment(@PathVariable Long id, @Validated @RequestBody PaymentDTO dto) {
        Payment payment = paymentService.updatePayment(id, dto);
        return Result.success(payment);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deletePayment(@PathVariable Long id) {
        paymentService.deletePayment(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<Payment>> queryPayments(PaymentQueryDTO queryDTO) {
        Page<Payment> page = paymentService.queryPayments(queryDTO);
        return Result.success(page);
    }

    @GetMapping("/methods")
    public Result<List<PaymentMethod>> listPaymentMethods() {
        List<PaymentMethod> list = paymentMethodService.listPaymentMethods();
        return Result.success(list);
    }

    @GetMapping("/methods/{id}")
    public Result<PaymentMethod> getPaymentMethodById(@PathVariable Long id) {
        PaymentMethod method = paymentMethodService.getPaymentMethodById(id);
        return Result.success(method);
    }
}
