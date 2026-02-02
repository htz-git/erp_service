package com.erplist.refund.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.refund.dto.RefundApplicationDTO;
import com.erplist.refund.dto.RefundApplicationQueryDTO;
import com.erplist.refund.entity.RefundApplication;

/**
 * 退款申请服务接口（支持 zid/sid 多租户）
 */
public interface RefundApplicationService {

    RefundApplication createRefundApplication(RefundApplicationDTO dto);

    RefundApplication getRefundApplicationById(Long id);

    RefundApplication updateRefundApplication(Long id, RefundApplicationDTO dto);

    void deleteRefundApplication(Long id);

    Page<RefundApplication> queryRefundApplications(RefundApplicationQueryDTO queryDTO);
}
