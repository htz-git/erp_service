package com.erplist.user.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 重置密码请求
 */
@Data
public class ResetPasswordRequest {
    @NotBlank(message = "新密码不能为空")
    private String newPassword;
}
