package com.erplist.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 审计日志记录请求 DTO（供其他服务通过内部接口写入审计）
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuditLogRecordDTO {
    private Long operatorId;
    private String operatorName;
    private String actionType;
    private String targetType;
    private String targetId;
    private String detail;
}
