package com.erplist.payment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.payment.entity.PaymentMethod;
import org.apache.ibatis.annotations.Mapper;

/**
 * 支付方式 Mapper
 */
@Mapper
public interface PaymentMethodMapper extends BaseMapper<PaymentMethod> {
}
