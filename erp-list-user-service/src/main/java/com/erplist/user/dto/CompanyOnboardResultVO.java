package com.erplist.user.dto;

import com.erplist.user.entity.Company;
import com.erplist.user.entity.User;
import lombok.Data;

/**
 * 开通公司结果：公司 + 超管账号（含初始密码提示）
 */
@Data
public class CompanyOnboardResultVO {
    private Company company;
    /** 该公司超管用户（不含密码，initialPassword 为创建时设置的密码，仅此处返回一次） */
    private User adminUser;
    /** 初始密码（仅开通时返回，供管理员告知客户） */
    private String initialPassword;
}
