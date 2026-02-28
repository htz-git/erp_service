package com.erplist.refund.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.refund.dto.RefundApplicationDTO;
import com.erplist.refund.dto.RefundApplicationQueryDTO;
import com.erplist.refund.entity.RefundApplication;
import com.erplist.refund.entity.RefundReason;
import com.erplist.refund.service.RefundApplicationService;
import com.erplist.refund.service.RefundReasonService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 退款控制器（网关路径 /api/refunds）
 */
@RestController
@RequestMapping("/refunds")
@RequiredArgsConstructor
public class RefundController {

    private final RefundApplicationService refundApplicationService;
    private final RefundReasonService refundReasonService;

    @PostMapping
    public Result<RefundApplication> createRefundApplication(@Validated @RequestBody RefundApplicationDTO dto) {
        RefundApplication entity = refundApplicationService.createRefundApplication(dto);
        return Result.success(entity);
    }

    @GetMapping("/reasons")
    public Result<List<RefundReason>> listRefundReasons(@RequestParam(required = false) Integer status) {
        List<RefundReason> list = refundReasonService.listRefundReasons(status);
        return Result.success(list);
    }

    /**
     * 批量查询存在已退款记录的订单 ID，供订单列表展示“退款”标签
     * @param orderIds 订单 ID 列表，逗号分隔
     */
    @GetMapping("/order-ids-with-refund")
    public Result<List<Long>> getOrderIdsWithRefund(@RequestParam("orderIds") List<Long> orderIds) {
        List<Long> list = refundApplicationService.getOrderIdsWithRefund(orderIds);
        return Result.success(list);
    }

    @GetMapping("/{id}")
    public Result<RefundApplication> getRefundApplicationById(@PathVariable Long id) {
        RefundApplication entity = refundApplicationService.getRefundApplicationById(id);
        return Result.success(entity);
    }

    @PutMapping("/{id}")
    public Result<RefundApplication> updateRefundApplication(@PathVariable Long id, @Validated @RequestBody RefundApplicationDTO dto) {
        RefundApplication entity = refundApplicationService.updateRefundApplication(id, dto);
        return Result.success(entity);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteRefundApplication(@PathVariable Long id) {
        refundApplicationService.deleteRefundApplication(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<RefundApplication>> queryRefundApplications(RefundApplicationQueryDTO queryDTO) {
        Page<RefundApplication> page = refundApplicationService.queryRefundApplications(queryDTO);
        return Result.success(page);
    }
}
