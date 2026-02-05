package com.erplist.user.dto;

import lombok.Data;

/**
 * 数据查看-按公司维度：用户数、店铺数
 */
@Data
public class DataViewVO {
    private String zid;
    private String companyName;
    private Long userCount;
    private Long sellerCount;
}
