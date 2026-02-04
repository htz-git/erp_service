package com.erplist.user.controller;

import com.erplist.common.result.Result;
import com.erplist.user.entity.Permission;
import com.erplist.user.service.UserPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 权限与用户权限关联接口
 */
@RestController
@RequestMapping
@RequiredArgsConstructor
public class PermissionController {

    private final UserPermissionService userPermissionService;

    /**
     * 查询全部可选权限（供前端「增加权限」弹窗）
     */
    @GetMapping("/permissions")
    public Result<List<Permission>> listAllPermissions() {
        List<Permission> list = userPermissionService.listAllPermissions();
        return Result.success(list);
    }

    /**
     * 查询某用户拥有的权限列表
     */
    @GetMapping("/users/{id}/permissions")
    public Result<List<Permission>> getUserPermissions(@PathVariable Long id) {
        List<Permission> list = userPermissionService.getPermissionsByUserId(id);
        return Result.success(list);
    }

    /**
     * 为用户增加权限（body 传 permissionId 列表）
     */
    @PostMapping("/users/{id}/permissions")
    public Result<Void> addUserPermissions(@PathVariable Long id, @RequestBody List<Long> permissionIds) {
        userPermissionService.addPermissions(id, permissionIds);
        return Result.success();
    }

    /**
     * 移除用户某条权限
     */
    @DeleteMapping("/users/{id}/permissions/{permissionId}")
    public Result<Void> removeUserPermission(@PathVariable Long id, @PathVariable Long permissionId) {
        userPermissionService.removePermission(id, permissionId);
        return Result.success();
    }

    /**
     * 判断用户是否拥有指定权限（供店铺/商品等服务通过 Feign 调用）
     */
    @GetMapping("/users/{userId}/has-permission")
    public Result<Boolean> hasPermission(@PathVariable Long userId, @RequestParam String permissionCode) {
        boolean has = userPermissionService.hasPermission(userId, permissionCode);
        return Result.success(has);
    }
}
