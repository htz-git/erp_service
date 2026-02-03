package com.erplist.seller.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 店铺 DTO（创建/更新）
 */
@Data
public class SellerDTO {
    private Long id;

    @NotBlank(message = "店铺名称不能为空")
    private String sellerName;

    private String platform;

    private String platformAccount;

    private String accessToken;

    private String refreshToken;

    private java.time.LocalDateTime tokenExpireTime;

    private Integer status;

    private java.time.LocalDateTime authorizeTime;

    private String remark;

    private Long userId;

    /** 公司ID（与 user.zid 一致），创建时未传则从 UserContext 取 */
    private String zid;
}
