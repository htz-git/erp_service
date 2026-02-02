package com.erplist.refund.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.refund.entity.RefundReason;
import org.apache.ibatis.annotations.Mapper;

/**
 * 退款原因 Mapper
 */
@Mapper
public interface RefundReasonMapper extends BaseMapper<RefundReason> {
}
