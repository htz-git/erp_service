package com.erplist.replenishment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.replenishment.entity.Inventory;
import org.apache.ibatis.annotations.Mapper;

/**
 * 库存 Mapper
 */
@Mapper
public interface InventoryMapper extends BaseMapper<Inventory> {
}
