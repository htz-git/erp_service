package com.erplist.user.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 当前用户修改密码请求
 */
@Data
public class ChangePasswordRequest {
    @NotBlank(message = "原密码不能为空")
    private String oldPassword;

    @NotBlank(message = "新密码不能为空")
    private String newPassword;
}
