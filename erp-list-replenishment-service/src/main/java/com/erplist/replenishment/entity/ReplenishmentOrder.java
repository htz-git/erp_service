package com.erplist.replenishment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 补货单实体
 */
@Data
@TableName("replenishment_order")
public class ReplenishmentOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String replenishmentNo;
    private Long warehouseId;
    private String warehouseName;
    private String zid;
    private Long sid;
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
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @TableLogic
    private Integer deleted;
}
