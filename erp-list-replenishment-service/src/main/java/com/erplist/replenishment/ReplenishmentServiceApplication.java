package com.erplist.replenishment;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"com.erplist.replenishment", "com.erplist.common"})
@MapperScan("com.erplist.replenishment.mapper")
@EnableFeignClients(basePackages = "com.erplist.api.client")
public class ReplenishmentServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(ReplenishmentServiceApplication.class, args);
    }
}

