package com.erplist.refund.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.refund.dto.RefundApplicationDTO;
import com.erplist.refund.dto.RefundApplicationQueryDTO;
import com.erplist.refund.dto.RefundListVO;
import com.erplist.refund.entity.RefundApplication;

import java.util.List;

/**
 * 退款申请服务接口（支持 zid/sid 多租户）
 */
public interface RefundApplicationService {

    RefundApplication createRefundApplication(RefundApplicationDTO dto);

    RefundApplication getRefundApplicationById(Long id);

    RefundApplication updateRefundApplication(Long id, RefundApplicationDTO dto);

    void deleteRefundApplication(Long id);

    Page<RefundListVO> queryRefundApplications(RefundApplicationQueryDTO queryDTO);

    /**
     * 批量查询哪些订单存在已退款记录（refundStatus=1 已通过），供订单列表展示“退款”标签
     */
    List<Long> getOrderIdsWithRefund(List<Long> orderIds);
}
