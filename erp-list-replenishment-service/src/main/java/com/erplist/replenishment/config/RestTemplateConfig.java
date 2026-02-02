package com.erplist.replenishment.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

/**
 * RestTemplate 配置（用于调用 LSTM 预测服务等外部 HTTP）
 */
@Configuration
public class RestTemplateConfig {

    @Bean
    public RestTemplate restTemplate(LstmForecastProperties lstmProps) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(lstmProps.getConnectTimeout());
        factory.setReadTimeout(lstmProps.getReadTimeout());
        return new RestTemplate(factory);
    }
}
