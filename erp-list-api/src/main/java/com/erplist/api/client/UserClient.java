package com.erplist.api.client;

import com.erplist.api.dto.AuditLogRecordDTO;
import com.erplist.common.result.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 用户服务 Feign 客户端（供店铺/商品等服务做权限校验及写审计日志）
 */
@FeignClient(name = "erp-list-user-service", contextId = "userClient", configuration = com.erplist.api.config.DefaultFeignConfig.class)
public interface UserClient {

    /**
     * 判断用户是否拥有指定权限
     *
     * @param userId         用户ID（一般为当前请求用户）
     * @param permissionCode 权限编码，如 seller:create、seller:delete、product:create
     * @return data 为 true 表示有权限，false 表示无权限
     */
    @GetMapping("/users/{userId}/has-permission")
    Result<Boolean> hasPermission(@PathVariable("userId") Long userId, @RequestParam("permissionCode") String permissionCode);

    /**
     * 记录审计日志（内部接口，供其他服务在完成操作后写入审计）
     */
    @PostMapping("/internal/audit-logs")
    Result<Void> recordAuditLog(@RequestBody AuditLogRecordDTO dto);
}

