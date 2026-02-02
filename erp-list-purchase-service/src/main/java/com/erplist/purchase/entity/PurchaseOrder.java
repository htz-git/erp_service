package com.erplist.purchase.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 采购单实体
 */
@Data
@TableName("purchase_order")
public class PurchaseOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String purchaseNo;
    private Long supplierId;
    private String supplierName;
    private String zid;
    private Long sid;
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
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @TableLogic
    private Integer deleted;
}
