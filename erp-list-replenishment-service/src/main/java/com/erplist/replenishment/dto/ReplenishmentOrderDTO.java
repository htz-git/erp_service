package com.erplist.replenishment.dto;

import lombok.Data;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 补货单 DTO（创建/更新）
 */
@Data
public class ReplenishmentOrderDTO {
    private Long id;
    private String replenishmentNo;
    private Long warehouseId;
    private String warehouseName;
    private String zid;
    private Long sid;

    @NotNull(message = "补货总金额不能为空")
    private BigDecimal totalAmount;

    private Integer replenishmentStatus;
    private Long operatorId;
    private String operatorName;
    private LocalDateTime approveTime;
    private Long approverId;
    private String approverName;
    private LocalDateTime expectedArrivalTime;
    private LocalDateTime arrivalTime;
    private String remark;
    private List<ReplenishmentItemDTO> items;
}
