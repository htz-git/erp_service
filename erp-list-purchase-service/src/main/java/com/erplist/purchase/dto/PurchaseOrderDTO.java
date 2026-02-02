package com.erplist.purchase.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 采购单 DTO（创建/更新）
 */
@Data
public class PurchaseOrderDTO {
    private Long id;
    private String purchaseNo;

    @NotNull(message = "供应商ID不能为空")
    private Long supplierId;

    private String supplierName;
    private String zid;
    private Long sid;

    @NotNull(message = "采购总金额不能为空")
    private BigDecimal totalAmount;

    private Integer purchaseStatus;
    private Long purchaserId;
    private String purchaserName;
    private LocalDateTime approveTime;
    private Long approverId;
    private String approverName;
    private LocalDateTime expectedArrivalTime;
    private LocalDateTime arrivalTime;
    private String remark;
    private List<PurchaseItemDTO> items;
}
