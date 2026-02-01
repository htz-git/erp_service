package com.erplist.purchase;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@MapperScan("com.erplist.purchase.mapper")
@EnableFeignClients(basePackages = "com.erplist.api.client")
public class PurchaseServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(PurchaseServiceApplication.class, args);
    }
}

