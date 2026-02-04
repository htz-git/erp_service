package com.erplist.user.service;

import com.erplist.user.entity.Permission;

import java.util.List;

/**
 * 用户权限服务（一账号对应多权限）
 */
public interface UserPermissionService {

    /**
     * 查询用户拥有的权限编码列表
     */
    List<String> getPermissionCodesByUserId(Long userId);

    /**
     * 查询用户拥有的权限列表（含 id、name、code）
     */
    List<Permission> getPermissionsByUserId(Long userId);

    /**
     * 判断用户是否拥有指定权限
     */
    boolean hasPermission(Long userId, String permissionCode);

    /**
     * 查询全部可选权限（供前端「增加权限」弹窗）
     */
    List<Permission> listAllPermissions();

    /**
     * 为用户增加权限（按 permissionId 列表）
     */
    void addPermissions(Long userId, List<Long> permissionIds);

    /**
     * 移除用户某条权限
     */
    void removePermission(Long userId, Long permissionId);
}
