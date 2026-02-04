package com.erplist.order.dto;

import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.util.List;

/**
 * 订单查询 DTO（分页，支持 zid/sid、时间范围、国家多选）
 */
@Data
public class OrderQueryDTO {
    private String orderNo;
    private Long userId;
    private String zid;
    private Long sid;
    /** 国家代码多选筛选（如 US、DE） */
    private List<String> countryCodes;
    private Integer orderStatus;
    private Integer payStatus;
    /** 创建时间起（按日期，含当天 0 点） */
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate createTimeStart;
    /** 创建时间止（按日期，含当天 23:59:59） */
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate createTimeEnd;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
