package com.erplist.payment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.payment.entity.PaymentFlow;
import org.apache.ibatis.annotations.Mapper;

/**
 * 支付流水 Mapper
 */
@Mapper
public interface PaymentFlowMapper extends BaseMapper<PaymentFlow> {
}
