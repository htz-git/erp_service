package com.erplist.purchase.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.purchase.entity.PurchaseItem;
import org.apache.ibatis.annotations.Mapper;

/**
 * 采购明细 Mapper
 */
@Mapper
public interface PurchaseItemMapper extends BaseMapper<PurchaseItem> {
}
