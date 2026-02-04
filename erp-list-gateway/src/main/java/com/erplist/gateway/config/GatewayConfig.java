package com.erplist.gateway.config;

import com.erplist.gateway.filter.UserContextGatewayFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class GatewayConfig {

    @Bean
    public WebClient webClient() {
        return WebClient.builder().build();
    }

    @Bean
    public UserContextGatewayFilter userContextGatewayFilter(WebClient webClient,
                                                             org.springframework.cloud.client.discovery.DiscoveryClient discoveryClient) {
        return new UserContextGatewayFilter(webClient, discoveryClient);
    }
}
