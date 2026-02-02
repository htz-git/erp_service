package com.erplist.purchase.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 采购状态记录实体
 */
@Data
@TableName("purchase_status_log")
public class PurchaseStatusLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long purchaseId;
    private String purchaseNo;
    private Integer oldStatus;
    private Integer newStatus;
    private Long operatorId;
    private String operatorName;
    private String remark;
    private LocalDateTime createTime;
}
