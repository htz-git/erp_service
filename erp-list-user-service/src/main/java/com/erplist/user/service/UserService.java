package com.erplist.user.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.user.dto.AdminUserQueryDTO;
import com.erplist.user.dto.LoginDTO;
import com.erplist.user.dto.LoginResultDTO;
import com.erplist.user.dto.UserDTO;
import com.erplist.user.dto.UserQueryDTO;
import com.erplist.user.entity.User;

/**
 * 用户服务接口
 */
public interface UserService {
    
    /**
     * 创建用户
     */
    User createUser(UserDTO userDTO);
    
    /**
     * 根据ID查询用户
     */
    User getUserById(Long id);
    
    /**
     * 根据用户名查询用户
     */
    User getUserByUsername(String username);
    
    /**
     * 更新用户
     */
    User updateUser(Long id, UserDTO userDTO);
    
    /**
     * 删除用户
     */
    void deleteUser(Long id);
    
    /**
     * 分页查询用户
     */
    Page<User> queryUsers(UserQueryDTO queryDTO);
    
    /**
     * 启用/禁用用户
     */
    void updateStatus(Long id, Integer status);
    
    /**
     * 用户登录
     */
    LoginResultDTO login(LoginDTO loginDTO);
    
    /**
     * 根据token获取用户信息
     */
    User getUserByToken(String token);

    /**
     * 管理端：全平台用户分页查询（不按 zid 过滤）
     */
    Page<User> listAllUsers(AdminUserQueryDTO queryDTO);

    /**
     * 管理端：重置指定用户密码
     */
    void resetPassword(Long userId, String newPassword);

    /**
     * 按 zid 统计用户数（用于数据查看）
     */
    long countUsersByZid(String zid);
}

