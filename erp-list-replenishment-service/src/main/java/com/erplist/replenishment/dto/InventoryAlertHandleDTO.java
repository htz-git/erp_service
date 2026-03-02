package com.erplist.replenishment.dto;

import lombok.Data;

/**
 * 库存预警标记已处理 DTO
 */
@Data
public class InventoryAlertHandleDTO {
    /** 处理人ID（可选，不传则用当前用户） */
    private Long handlerId;
    /** 处理人姓名（可选） */
    private String handlerName;
}
