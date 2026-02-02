package com.erplist.replenishment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.replenishment.entity.ReplenishmentItem;
import org.apache.ibatis.annotations.Mapper;

/**
 * 补货明细 Mapper
 */
@Mapper
public interface ReplenishmentItemMapper extends BaseMapper<ReplenishmentItem> {
}
