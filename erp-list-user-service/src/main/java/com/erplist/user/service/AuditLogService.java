package com.erplist.user.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.user.dto.AuditLogQueryDTO;
import com.erplist.user.entity.AuditLog;

/**
 * 审计日志服务
 */
public interface AuditLogService {

    /**
     * 记录操作日志
     */
    void save(Long operatorId, String operatorName, String actionType, String targetType, String targetId, String detail);

    /**
     * 分页查询操作日志
     */
    Page<AuditLog> list(AuditLogQueryDTO query);
}
