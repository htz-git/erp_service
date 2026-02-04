package com.erplist.user.filter;

import com.erplist.common.utils.UserContext;
import com.erplist.user.entity.User;
import com.erplist.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.lang.NonNull;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * 从 Authorization Bearer token 解析当前用户并写入 UserContext，供后续按 zid 隔离使用。
 * 登录接口 POST /users/login 不解析 token，直接放行。
 */
@Component
@Order(1)
@RequiredArgsConstructor
public class UserContextFilter extends OncePerRequestFilter {

    private final UserService userService;

    private static final String LOGIN_PATH = "/users/login";
    private static final String BEARER_PREFIX = "Bearer ";

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        try {
            if (isLoginRequest(request)) {
                filterChain.doFilter(request, response);
                return;
            }
            String token = extractToken(request);
            if (StringUtils.hasText(token)) {
                User user = userService.getUserByToken(token);
                if (user != null) {
                    UserContext.setUserId(user.getId());
                    if (StringUtils.hasText(user.getZid())) {
                        UserContext.setZid(user.getZid());
                    }
                }
            }
            filterChain.doFilter(request, response);
        } finally {
            UserContext.remove();
        }
    }

    private boolean isLoginRequest(HttpServletRequest request) {
        return "POST".equalsIgnoreCase(request.getMethod())
                && request.getRequestURI() != null
                && request.getRequestURI().endsWith(LOGIN_PATH);
    }

    private String extractToken(HttpServletRequest request) {
        String auth = request.getHeader("Authorization");
        if (auth != null && auth.startsWith(BEARER_PREFIX)) {
            return auth.substring(BEARER_PREFIX.length()).trim();
        }
        return null;
    }
}
