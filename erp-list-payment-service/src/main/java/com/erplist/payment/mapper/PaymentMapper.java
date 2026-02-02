package com.erplist.payment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.payment.entity.Payment;
import org.apache.ibatis.annotations.Mapper;

/**
 * 支付记录 Mapper
 */
@Mapper
public interface PaymentMapper extends BaseMapper<Payment> {
}
