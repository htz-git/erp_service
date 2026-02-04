package com.erplist.user.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.user.entity.Permission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 权限 Mapper
 */
@Mapper
public interface PermissionMapper extends BaseMapper<Permission> {

    /**
     * 根据用户ID查询其拥有的权限编码列表（通过 user_permission 关联）
     */
    @Select("SELECT p.permission_code FROM permission p " +
            "INNER JOIN user_permission up ON up.permission_id = p.id " +
            "WHERE up.user_id = #{userId}")
    List<String> selectPermissionCodesByUserId(@Param("userId") Long userId);
}
