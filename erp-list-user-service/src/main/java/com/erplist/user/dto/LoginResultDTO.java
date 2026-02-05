package com.erplist.user.dto;

import lombok.Data;

/**
 * 登录结果DTO
 */
@Data
public class LoginResultDTO {
    private String token;
    private UserDTO user;
    /** 是否为平台管理员（可跳转管理后台） */
    private Boolean isAdmin;
}

