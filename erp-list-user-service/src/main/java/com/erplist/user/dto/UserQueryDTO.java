package com.erplist.user.dto;

import lombok.Data;

/**
 * 用户查询DTO
 */
@Data
public class UserQueryDTO {
    private String username;
    private String phone;
    private String email;
    private Integer status;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}

