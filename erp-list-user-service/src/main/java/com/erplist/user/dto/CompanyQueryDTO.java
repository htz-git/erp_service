package com.erplist.user.dto;

import lombok.Data;

/**
 * 管理端-公司查询 DTO
 */
@Data
public class CompanyQueryDTO {
    private String zid;
    private String companyName;
    private Integer status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
