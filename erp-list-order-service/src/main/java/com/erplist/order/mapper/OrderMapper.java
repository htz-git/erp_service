package com.erplist.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.api.dto.CountryOrderCountDTO;
import com.erplist.order.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

/**
 * 订单 Mapper
 */
@Mapper
public interface OrderMapper extends BaseMapper<Order> {

    /**
     * 按国家统计订单数（供首页地图使用）
     */
    List<CountryOrderCountDTO> selectOrderCountByCountry(
            @Param("zid") String zid,
            @Param("sid") Long sid,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
