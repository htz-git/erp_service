package com.erplist.user.dto;

import lombok.Data;

/**
 * 审计日志查询 DTO
 */
@Data
public class AuditLogQueryDTO {
    private String actionType;
    private String targetType;
    private String targetId;
    private Long operatorId;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
