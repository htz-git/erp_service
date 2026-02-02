package com.erplist.purchase.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.purchase.entity.PurchaseOrder;
import org.apache.ibatis.annotations.Mapper;

/**
 * 采购单 Mapper
 */
@Mapper
public interface PurchaseOrderMapper extends BaseMapper<PurchaseOrder> {
}
