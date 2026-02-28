package com.erplist.refund.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.refund.dto.RefundApplicationDTO;
import com.erplist.refund.dto.RefundApplicationQueryDTO;
import com.erplist.refund.dto.RefundListVO;
import com.erplist.refund.entity.RefundApplication;
import com.erplist.refund.entity.RefundReason;
import com.erplist.refund.service.RefundApplicationService;
import com.erplist.refund.service.RefundReasonService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

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
     * @param orderIds 订单 ID 列表，逗号分隔，如 1,2,3
     */
    @GetMapping("/order-ids-with-refund")
    public Result<List<Long>> getOrderIdsWithRefund(@RequestParam(value = "orderIds", required = false) String orderIdsStr) {
        List<Long> orderIds = parseOrderIds(orderIdsStr);
        List<Long> list = refundApplicationService.getOrderIdsWithRefund(orderIds);
        return Result.success(list);
    }

    private static List<Long> parseOrderIds(String orderIdsStr) {
        if (orderIdsStr == null || orderIdsStr.trim().isEmpty()) {
            return Collections.emptyList();
        }
        try {
            return Arrays.stream(orderIdsStr.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(Long::parseLong)
                .collect(Collectors.toList());
        } catch (NumberFormatException e) {
            return Collections.emptyList();
        }
    }

    @GetMapping("/{id:\\d+}")
    public Result<RefundApplication> getRefundApplicationById(@PathVariable Long id) {
        RefundApplication entity = refundApplicationService.getRefundApplicationById(id);
        return Result.success(entity);
    }

    @PutMapping("/{id:\\d+}")
    public Result<RefundApplication> updateRefundApplication(@PathVariable Long id, @Validated @RequestBody RefundApplicationDTO dto) {
        RefundApplication entity = refundApplicationService.updateRefundApplication(id, dto);
        return Result.success(entity);
    }

    @DeleteMapping("/{id:\\d+}")
    public Result<Void> deleteRefundApplication(@PathVariable Long id) {
        refundApplicationService.deleteRefundApplication(id);
        return Result.success();
    }

    @GetMapping
    public Result<Page<RefundListVO>> queryRefundApplications(RefundApplicationQueryDTO queryDTO) {
        Page<RefundListVO> page = refundApplicationService.queryRefundApplications(queryDTO);
        return Result.success(page);
    }
}
