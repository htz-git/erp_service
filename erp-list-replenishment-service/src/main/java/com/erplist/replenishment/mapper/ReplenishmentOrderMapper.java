package com.erplist.replenishment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.replenishment.entity.ReplenishmentOrder;
import org.apache.ibatis.annotations.Mapper;

/**
 * 补货单 Mapper
 */
@Mapper
public interface ReplenishmentOrderMapper extends BaseMapper<ReplenishmentOrder> {
}
