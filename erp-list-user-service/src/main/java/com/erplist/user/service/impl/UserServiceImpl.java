package com.erplist.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.user.constant.AdminConstant;
import com.erplist.user.dto.AdminUserQueryDTO;
import com.erplist.user.dto.LoginDTO;
import com.erplist.user.dto.LoginResultDTO;
import com.erplist.user.dto.UserDTO;
import com.erplist.user.dto.UserQueryDTO;
import com.erplist.user.entity.User;
import com.erplist.user.mapper.UserMapper;
import com.erplist.user.service.UserPermissionService;
import com.erplist.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 用户服务实现
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final UserPermissionService userPermissionService;
    
    // 简单的token存储（实际项目中应使用Redis或JWT）
    private static final ConcurrentHashMap<String, User> TOKEN_MAP = new ConcurrentHashMap<>();
    
    @Override
    public User createUser(UserDTO userDTO) {
        String zid = com.erplist.common.utils.UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，无法创建用户");
        }

        // 检查用户名是否已存在
        User existUser = userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getUsername, userDTO.getUsername())
        );
        if (existUser != null) {
            throw new BusinessException("用户名已存在");
        }
        
        // 检查手机号是否已存在
        if (StringUtils.hasText(userDTO.getPhone())) {
            User existPhone = userMapper.selectOne(
                new LambdaQueryWrapper<User>()
                    .eq(User::getPhone, userDTO.getPhone())
            );
            if (existPhone != null) {
                throw new BusinessException("手机号已被注册");
            }
        }
        
        User user = new User();
        BeanUtils.copyProperties(userDTO, user);
        user.setZid(zid);
        user.setStatus(1); // 默认启用
        // TODO: 密码加密，建议使用BCryptPasswordEncoder
        // 暂时直接存储，实际项目中必须加密
        userMapper.insert(user);
        return user;
    }
    
    @Override
    public User getUserById(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        // 不返回密码
        user.setPassword(null);
        return user;
    }
    
    @Override
    public User getUserByUsername(String username) {
        return userMapper.selectOne(
            new LambdaQueryWrapper<User>()
                .eq(User::getUsername, username)
        );
    }
    
    @Override
    public User updateUser(Long id, UserDTO userDTO) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        // 如果修改手机号，检查是否已被其他用户使用
        if (StringUtils.hasText(userDTO.getPhone()) && !userDTO.getPhone().equals(user.getPhone())) {
            User existPhone = userMapper.selectOne(
                new LambdaQueryWrapper<User>()
                    .eq(User::getPhone, userDTO.getPhone())
                    .ne(User::getId, id)
            );
            if (existPhone != null) {
                throw new BusinessException("手机号已被其他用户使用");
            }
        }
        
        BeanUtils.copyProperties(userDTO, user, "id", "password", "username");
        userMapper.updateById(user);
        // 不返回密码
        user.setPassword(null);
        return user;
    }
    
    @Override
    public void deleteUser(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        userMapper.deleteById(id);
    }
    
    @Override
    public Page<User> queryUsers(UserQueryDTO queryDTO) {
        String zid = com.erplist.common.utils.UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的用户");
        }

        Page<User> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getZid, zid);
        
        if (StringUtils.hasText(queryDTO.getUsername())) {
            wrapper.like(User::getUsername, queryDTO.getUsername());
        }
        if (StringUtils.hasText(queryDTO.getPhone())) {
            wrapper.eq(User::getPhone, queryDTO.getPhone());
        }
        if (StringUtils.hasText(queryDTO.getEmail())) {
            wrapper.like(User::getEmail, queryDTO.getEmail());
        }
        if (queryDTO.getStatus() != null) {
            wrapper.eq(User::getStatus, queryDTO.getStatus());
        }
        
        wrapper.orderByDesc(User::getCreateTime);
        Page<User> result = userMapper.selectPage(page, wrapper);
        // 清除密码信息
        result.getRecords().forEach(u -> u.setPassword(null));
        return result;
    }
    
    @Override
    public void updateStatus(Long id, Integer status) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        if (status != 0 && status != 1) {
            throw new BusinessException("状态值不合法");
        }
        user.setStatus(status);
        userMapper.updateById(user);
    }
    
    @Override
    public LoginResultDTO login(LoginDTO loginDTO) {
        User user = getUserByUsername(loginDTO.getUsername());
        if (user == null || user.getDeleted() == 1) {
            throw new BusinessException("用户名或密码错误");
        }
        if (user.getStatus() == 0) {
            throw new BusinessException("用户已被禁用");
        }
        
        // 简单的密码验证（实际项目中应使用BCryptPasswordEncoder）
        if (!user.getPassword().equals(loginDTO.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }
        
        // 生成token
        String token = UUID.randomUUID().toString().replace("-", "");
        TOKEN_MAP.put(token, user);
        
        LoginResultDTO result = new LoginResultDTO();
        UserDTO userDTO = new UserDTO();
        BeanUtils.copyProperties(user, userDTO);
        userDTO.setPassword(null);
        result.setToken(token);
        result.setUser(userDTO);
        result.setIsAdmin(AdminConstant.ADMIN_ZID.equals(user.getZid())
                && userPermissionService.hasPermission(user.getId(), AdminConstant.ADMIN_ACCESS));

        return result;
    }

    @Override
    public Page<User> listAllUsers(AdminUserQueryDTO queryDTO) {
        Page<User> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(queryDTO.getZid())) {
            wrapper.eq(User::getZid, queryDTO.getZid());
        }
        if (StringUtils.hasText(queryDTO.getUsername())) {
            wrapper.like(User::getUsername, queryDTO.getUsername());
        }
        if (queryDTO.getStatus() != null) {
            wrapper.eq(User::getStatus, queryDTO.getStatus());
        }
        wrapper.orderByDesc(User::getCreateTime);
        Page<User> result = userMapper.selectPage(page, wrapper);
        result.getRecords().forEach(u -> u.setPassword(null));
        return result;
    }

    @Override
    public void resetPassword(Long userId, String newPassword) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        user.setPassword(newPassword); // TODO: 加密
        userMapper.updateById(user);
    }

    @Override
    public long countUsersByZid(String zid) {
        if (!StringUtils.hasText(zid)) return 0;
        return userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getZid, zid));
    }

    @Override
    public User getUserByToken(String token) {
        return TOKEN_MAP.get(token);
    }
}

