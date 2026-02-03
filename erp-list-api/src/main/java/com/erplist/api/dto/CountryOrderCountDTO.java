package com.erplist.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 按国家统计订单数 DTO（供首页地图使用）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CountryOrderCountDTO {
    /** 国家/地区代码（如 ISO 3166-1 alpha-2） */
    private String countryCode;
    /** 国家/地区名称（可选，可由前端根据 code 映射） */
    private String countryName;
    /** 订单数 */
    private Long orderCount;
}
