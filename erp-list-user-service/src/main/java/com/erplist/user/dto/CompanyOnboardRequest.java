package com.erplist.user.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 开通公司（onboard）请求：公司信息 + 超管账号信息
 */
@Data
public class CompanyOnboardRequest {

    /** 公司名称 */
    @NotBlank(message = "公司名称不能为空")
    private String companyName;
    private String contactName;
    private String contactPhone;
    private String contactEmail;
    /** 公司地址（选填） */
    private String address;
    private String remark;

    /** 超管用户名 */
    @NotBlank(message = "超管用户名不能为空")
    private String adminUsername;
    /** 超管密码 */
    @NotBlank(message = "超管密码不能为空")
    private String adminPassword;
    private String adminRealName;
    private String adminPhone;
    private String adminEmail;
}
