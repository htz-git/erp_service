package com.erplist.user.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.user.entity.UserPermission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户-权限关联 Mapper
 */
@Mapper
public interface UserPermissionMapper extends BaseMapper<UserPermission> {
}
