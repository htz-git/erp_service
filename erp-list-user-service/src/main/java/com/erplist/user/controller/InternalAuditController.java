package com.erplist.user.controller;

import com.erplist.common.result.Result;
import com.erplist.api.dto.AuditLogRecordDTO;
import com.erplist.user.entity.User;
import com.erplist.user.mapper.UserMapper;
import com.erplist.user.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 内部审计接口，供其他微服务（如店铺服务）在完成操作后写入审计日志。
 * 仅服务间调用，网关需配置不对外暴露 /internal/*
 */
@RestController
@RequestMapping("/internal")
@RequiredArgsConstructor
public class InternalAuditController {

    private static final int DETAIL_MAX_LENGTH = 500;

    private final AuditLogService auditLogService;
    private final UserMapper userMapper;

    @PostMapping("/audit-logs")
    public Result<Void> recordAuditLog(@RequestBody AuditLogRecordDTO dto) {
        if (!StringUtils.hasText(dto.getActionType()) || !StringUtils.hasText(dto.getTargetType()) || !StringUtils.hasText(dto.getTargetId())) {
            return Result.error("actionType、targetType、targetId 不能为空");
        }
        String detail = dto.getDetail();
        if (detail != null && detail.length() > DETAIL_MAX_LENGTH) {
            detail = detail.substring(0, DETAIL_MAX_LENGTH);
        }
        // 若调用方未传操作人名称，则根据 operatorId 查询并展示（如 zid=1 的超管会显示其用户名）
        String operatorName = dto.getOperatorName();
        if (!StringUtils.hasText(operatorName) && dto.getOperatorId() != null) {
            User operator = userMapper.selectById(dto.getOperatorId());
            if (operator != null) {
                operatorName = StringUtils.hasText(operator.getRealName()) ? operator.getRealName() : operator.getUsername();
            }
        }
        auditLogService.save(dto.getOperatorId(), operatorName, dto.getActionType(), dto.getTargetType(), dto.getTargetId(), detail);
        return Result.success();
    }
}
