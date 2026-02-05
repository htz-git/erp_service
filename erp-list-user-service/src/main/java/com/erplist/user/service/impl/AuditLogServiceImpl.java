package com.erplist.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.user.dto.AuditLogQueryDTO;
import com.erplist.user.entity.AuditLog;
import com.erplist.user.mapper.AuditLogMapper;
import com.erplist.user.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

/**
 * 审计日志服务实现
 */
@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogMapper auditLogMapper;

    @Override
    public void save(Long operatorId, String operatorName, String actionType, String targetType, String targetId, String detail) {
        AuditLog log = new AuditLog();
        log.setOperatorId(operatorId);
        log.setOperatorName(operatorName);
        log.setActionType(actionType);
        log.setTargetType(targetType);
        log.setTargetId(targetId);
        log.setDetail(detail);
        auditLogMapper.insert(log);
    }

    @Override
    public Page<AuditLog> list(AuditLogQueryDTO query) {
        Page<AuditLog> page = new Page<>(query.getPageNum(), query.getPageSize());
        LambdaQueryWrapper<AuditLog> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(query.getActionType())) {
            wrapper.eq(AuditLog::getActionType, query.getActionType());
        }
        if (StringUtils.hasText(query.getTargetType())) {
            wrapper.eq(AuditLog::getTargetType, query.getTargetType());
        }
        if (StringUtils.hasText(query.getTargetId())) {
            wrapper.eq(AuditLog::getTargetId, query.getTargetId());
        }
        if (query.getOperatorId() != null) {
            wrapper.eq(AuditLog::getOperatorId, query.getOperatorId());
        }
        wrapper.orderByDesc(AuditLog::getCreateTime);
        return auditLogMapper.selectPage(page, wrapper);
    }
}
