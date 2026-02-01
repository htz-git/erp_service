package com.erplist.api.config;

import com.erplist.common.utils.UserContext;
import feign.Logger;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.context.annotation.Bean;

/**
 * Feign默认配置
 * 用于在服务间调用时传递用户信息
 */
public class DefaultFeignConfig {
    @Bean
    public Logger.Level feignLoggerLevel(){
        return Logger.Level.FULL;
    }

    @Bean
    public RequestInterceptor userInfoRequestInterceptor(){
        return new RequestInterceptor() {
            @Override
            public void apply(RequestTemplate template) {
                // 获取用户信息
                Long userId = UserContext.getUserId();
                String zid = UserContext.getZid();
                Long sid = UserContext.getSid();
                
                // 传递用户ID
                if(userId != null) {
                    template.header("user-id", userId.toString());
                }
                // 传递公司ID
                if(zid != null) {
                    template.header("user-zid", zid);
                }
                // 传递店铺ID
                if(sid != null) {
                    template.header("user-sid", sid.toString());
                }
            }
        };
    }
}


