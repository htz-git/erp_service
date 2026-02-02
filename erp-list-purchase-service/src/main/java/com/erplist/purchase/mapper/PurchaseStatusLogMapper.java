package com.erplist.purchase.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.purchase.entity.PurchaseStatusLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 采购状态记录 Mapper
 */
@Mapper
public interface PurchaseStatusLogMapper extends BaseMapper<PurchaseStatusLog> {
}
