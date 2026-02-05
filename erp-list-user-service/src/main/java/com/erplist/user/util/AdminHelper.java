package com.erplist.user.util;

import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.user.constant.AdminConstant;
import com.erplist.user.service.UserPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * 管理端校验：仅当当前用户为管理员（虚拟 zid + admin:access 权限）时放行
 */
@Component
@RequiredArgsConstructor
public class AdminHelper {

    private final UserPermissionService userPermissionService;

    /**
     * 校验当前用户为平台管理员，否则抛异常
     */
    public void ensureAdmin() {
        Long userId = UserContext.getUserId();
        String zid = UserContext.getZid();
        if (userId == null || !StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息");
        }
        if (!AdminConstant.ADMIN_ZID.equals(zid)) {
            throw new BusinessException(403, "无权限：仅平台管理员可操作");
        }
        if (!userPermissionService.hasPermission(userId, AdminConstant.ADMIN_ACCESS)) {
            throw new BusinessException(403, "无权限：需要管理员后台权限");
        }
    }

    /**
     * 判断当前用户是否为平台管理员
     */
    public boolean isAdmin() {
        Long userId = UserContext.getUserId();
        String zid = UserContext.getZid();
        if (userId == null || !StringUtils.hasText(zid) || !AdminConstant.ADMIN_ZID.equals(zid)) {
            return false;
        }
        return userPermissionService.hasPermission(userId, AdminConstant.ADMIN_ACCESS);
    }
}
