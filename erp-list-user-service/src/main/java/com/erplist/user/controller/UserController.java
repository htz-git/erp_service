package com.erplist.user.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.user.dto.LoginDTO;
import com.erplist.user.dto.LoginResultDTO;
import com.erplist.user.dto.UserDTO;
import com.erplist.user.dto.UserQueryDTO;
import com.erplist.user.entity.User;
import com.erplist.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    /**
     * 创建用户
     */
    @PostMapping
    public Result<User> createUser(@Validated @RequestBody UserDTO userDTO) {
        User user = userService.createUser(userDTO);
        return Result.success(user);
    }
    
    /**
     * 根据ID查询用户
     */
    @GetMapping("/{id}")
    public Result<User> getUserById(@PathVariable Long id) {
        User user = userService.getUserById(id);
        return Result.success(user);
    }
    
    /**
     * 更新用户
     */
    @PutMapping("/{id}")
    public Result<User> updateUser(@PathVariable Long id, 
                                   @Validated @RequestBody UserDTO userDTO) {
        User user = userService.updateUser(id, userDTO);
        return Result.success(user);
    }
    
    /**
     * 删除用户
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return Result.success();
    }
    
    /**
     * 分页查询用户
     */
    @GetMapping
    public Result<Page<User>> queryUsers(UserQueryDTO queryDTO) {
        Page<User> page = userService.queryUsers(queryDTO);
        return Result.success(page);
    }
    
    /**
     * 启用/禁用用户
     */
    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, 
                                     @RequestParam Integer status) {
        userService.updateStatus(id, status);
        return Result.success();
    }
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<LoginResultDTO> login(@Validated @RequestBody LoginDTO loginDTO) {
        LoginResultDTO result = userService.login(loginDTO);
        return Result.success(result);
    }
    
    /**
     * 获取当前用户信息
     */
    @GetMapping("/current")
    public Result<User> getCurrentUser(@RequestHeader(value = "Authorization", required = false) String token) {
        if (token == null || !token.startsWith("Bearer ")) {
            throw new com.erplist.common.exception.BusinessException("未登录");
        }
        String actualToken = token.substring(7);
        User user = userService.getUserByToken(actualToken);
        if (user == null) {
            throw new com.erplist.common.exception.BusinessException("登录已过期");
        }
        user.setPassword(null);
        return Result.success(user);
    }
}


