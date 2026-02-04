package com.erplist.gateway.config;

import org.springframework.cloud.client.loadbalancer.reactive.ReactorLoadBalancerExchangeFilterFunction;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class GatewayConfig {

    @Bean
    public WebClient loadBalancedWebClient(ReactorLoadBalancerExchangeFilterFunction lbExchangeFilterFunction) {
        return WebClient.builder()
                .filter(lbExchangeFilterFunction)
                .build();
    }
}
