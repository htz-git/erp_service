package com.erplist.common.interceptor;

import cn.hutool.core.util.StrUtil;
import com.erplist.common.utils.UserContext;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 用户信息拦截器
 * 从请求头中获取用户信息并保存到ThreadLocal
 */
public class UserInfoInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 1.获取请求头中的用户信息
        String userId = request.getHeader("user-id");
        String zid = request.getHeader("user-zid");
        String sid = request.getHeader("user-sid");
        
        // 2.保存到ThreadLocal
        if (StrUtil.isNotBlank(userId)) {
            UserContext.setUserId(Long.valueOf(userId));
        }
        if (StrUtil.isNotBlank(zid)) {
            UserContext.setZid(zid);
        }
        if (StrUtil.isNotBlank(sid)) {
            UserContext.setSid(Long.valueOf(sid));
        }
        
        // 3.放行
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        // 移除用户信息
        UserContext.remove();
    }
}

