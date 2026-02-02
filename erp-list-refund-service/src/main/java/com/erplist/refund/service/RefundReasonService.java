package com.erplist.refund.service;

import com.erplist.refund.entity.RefundReason;

import java.util.List;

/**
 * 退款原因服务接口（列表查询）
 */
public interface RefundReasonService {

    List<RefundReason> listRefundReasons(Integer status);
}
