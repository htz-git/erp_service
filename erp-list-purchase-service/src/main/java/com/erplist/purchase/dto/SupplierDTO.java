package com.erplist.purchase.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 供应商 DTO（创建/更新）
 */
@Data
public class SupplierDTO {
    private Long id;

    @NotBlank(message = "供应商名称不能为空")
    private String supplierName;

    @NotBlank(message = "供应商编码不能为空")
    private String supplierCode;

    private String contactName;
    private String contactPhone;
    private String contactEmail;
    private String address;
    private String bankName;
    private String bankAccount;
    private String taxNumber;
    private Integer status;
    private String remark;
}
