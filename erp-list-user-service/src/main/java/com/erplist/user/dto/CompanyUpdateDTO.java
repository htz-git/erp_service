package com.erplist.user.dto;

import lombok.Data;

/**
 * 管理端-公司更新 DTO
 */
@Data
public class CompanyUpdateDTO {
    private String companyName;
    private String contactName;
    private String contactPhone;
    private String contactEmail;
    private String address;
    private Integer status;
    private String remark;
}
