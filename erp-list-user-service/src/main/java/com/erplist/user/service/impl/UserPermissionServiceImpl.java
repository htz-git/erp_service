package com.erplist.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.user.entity.Permission;
import com.erplist.user.entity.User;
import com.erplist.user.entity.UserPermission;
import com.erplist.user.mapper.PermissionMapper;
import com.erplist.user.mapper.UserMapper;
import com.erplist.user.mapper.UserPermissionMapper;
import com.erplist.user.service.UserPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 用户权限服务实现
 */
@Service
@RequiredArgsConstructor
public class UserPermissionServiceImpl implements UserPermissionService {

    private final PermissionMapper permissionMapper;
    private final UserPermissionMapper userPermissionMapper;
    private final UserMapper userMapper;

    @Override
    public List<String> getPermissionCodesByUserId(Long userId) {
        if (userId == null) {
            return new ArrayList<>();
        }
        return permissionMapper.selectPermissionCodesByUserId(userId);
    }

    @Override
    public List<Permission> getPermissionsByUserId(Long userId) {
        if (userId == null) {
            return new ArrayList<>();
        }
        List<String> codes = permissionMapper.selectPermissionCodesByUserId(userId);
        if (CollectionUtils.isEmpty(codes)) {
            return new ArrayList<>();
        }
        LambdaQueryWrapper<Permission> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(Permission::getPermissionCode, codes);
        return permissionMapper.selectList(wrapper);
    }

    @Override
    public boolean hasPermission(Long userId, String permissionCode) {
        if (userId == null || !StringUtils.hasText(permissionCode)) {
            return false;
        }
        List<String> codes = permissionMapper.selectPermissionCodesByUserId(userId);
        return codes != null && codes.contains(permissionCode.trim());
    }

    @Override
    public List<Permission> listAllPermissions() {
        LambdaQueryWrapper<Permission> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(Permission::getSortOrder);
        return permissionMapper.selectList(wrapper);
    }

    @Override
    public void addPermissions(Long userId, List<Long> permissionIds) {
        if (userId == null || CollectionUtils.isEmpty(permissionIds)) {
            return;
        }
        ensureUserInSameZid(userId);
        for (Long permissionId : permissionIds) {
            if (permissionId == null) continue;
            Permission p = permissionMapper.selectById(permissionId);
            if (p == null) continue;
            long cnt = userPermissionMapper.selectCount(
                    new LambdaQueryWrapper<UserPermission>()
                            .eq(UserPermission::getUserId, userId)
                            .eq(UserPermission::getPermissionId, permissionId)
            );
            if (cnt > 0) continue;
            UserPermission up = new UserPermission();
            up.setUserId(userId);
            up.setPermissionId(permissionId);
            userPermissionMapper.insert(up);
        }
    }

    @Override
    public void removePermission(Long userId, Long permissionId) {
        if (userId == null || permissionId == null) {
            return;
        }
        ensureUserInSameZid(userId);
        userPermissionMapper.delete(
                new LambdaQueryWrapper<UserPermission>()
                        .eq(UserPermission::getUserId, userId)
                        .eq(UserPermission::getPermissionId, permissionId)
        );
    }

    private void ensureUserInSameZid(Long targetUserId) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息");
        }
        User user = userMapper.selectById(targetUserId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (!zid.equals(user.getZid())) {
            throw new BusinessException("无权限操作其他公司用户");
        }
    }
}
