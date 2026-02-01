package com.erplist.refund;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@MapperScan("com.erplist.refund.mapper")
@EnableFeignClients(basePackages = "com.erplist.api.client")
public class RefundServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(RefundServiceApplication.class, args);
    }
}


