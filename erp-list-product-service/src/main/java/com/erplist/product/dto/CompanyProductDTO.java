package com.erplist.product.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.time.LocalDateTime;

/**
 * 公司商品 DTO（创建/更新）
 */
@Data
public class CompanyProductDTO {
    private Long id;
    private String zid;
    private Long sid;
    @NotBlank(message = "商品名称不能为空")
    private String productName;
    private String productCode;
    private String skuCode;
    private String platformSku;
    private String imageUrl;
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
