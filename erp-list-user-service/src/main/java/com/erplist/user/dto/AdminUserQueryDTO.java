package com.erplist.user.dto;

import lombok.Data;

/**
 * 管理端-全平台用户查询 DTO
 */
@Data
public class AdminUserQueryDTO {
    private String zid;
    private String username;
    private Integer status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
