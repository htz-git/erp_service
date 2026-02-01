package com.erplist.user.dto;

import lombok.Data;

/**
 * 登录结果DTO
 */
@Data
public class LoginResultDTO {
    private String token;
    private UserDTO user;
}

