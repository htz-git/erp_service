package com.erplist.user.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;

/**
 * 用户DTO
 */
@Data
public class UserDTO {
    private Long id;
    
    @NotBlank(message = "用户名不能为空")
    private String username;
    
    @NotBlank(message = "密码不能为空")
    private String password;
    
    private String realName;
    
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;
    
    @Pattern(regexp = "^[A-Za-z0-9+_.-]+@(.+)$", message = "邮箱格式不正确")
    private String email;
    
    private String avatar;
    
    private Integer status;
    
    private String zid;
}

