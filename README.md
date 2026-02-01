# ERP List 微服务架构项目

## 项目简介

ERP List是一个基于Spring Cloud微服务架构的跨境电商管理系统，参考了erp项目的业务功能，使用hmall项目的微服务架构配置。

## 技术栈

### 后端
- Spring Boot 2.7.12
- Spring Cloud 2021.0.3
- Spring Cloud Alibaba 2021.0.4.0
- Nacos（服务注册与配置中心）
- Spring Cloud Gateway（网关）
- OpenFeign（服务间调用）
- MyBatis Plus 3.4.3
- MySQL 8.0.23
- Knife4j（API文档）

### 前端
- Vue 3
- Element Plus
- Vue Router
- Pinia（状态管理）
- Axios

## 项目结构

```
erp_list/
├── erp-list-common/          # 公共模块（工具类、异常处理、统一响应）
├── erp-list-api/             # API接口定义（Feign客户端）
├── erp-list-gateway/         # 网关服务
├── erp-list-user-service/    # 用户服务（用户、角色、权限）
├── erp-list-seller-service/  # 店铺服务（店铺授权）
├── erp-list-order-service/   # 订单服务（订单、订单明细）
├── erp-list-payment-service/ # 支付服务（支付记录、支付方式）
├── erp-list-promotion-service/ # 促销服务（优惠券、促销活动）
├── erp-list-purchase-service/ # 采购服务（采购单、供应商）
├── erp-list-refund-service/   # 退款服务（退款申请、退款记录）
├── erp-list-replenishment-service/ # 补货服务（补货单、库存预警）
├── sql/                       # SQL脚本
└── erp-list-frontend/         # 前端项目
```

## 数据库设计

### 多租户设计
- **zid**（公司ID）：VARCHAR(50)，一个用户对应一个公司
- **sid**（店铺ID）：BIGINT，引用seller表的id字段，一个公司可以有多个店铺

### 数据库列表
- `erp_list_user` - 用户服务数据库
- `erp_list_seller` - 店铺服务数据库
- `erp_list_order` - 订单服务数据库
- `erp_list_payment` - 支付服务数据库
- `erp_list_promotion` - 促销服务数据库
- `erp_list_purchase` - 采购服务数据库
- `erp_list_refund` - 退款服务数据库
- `erp_list_replenishment` - 补货服务数据库

## 服务端口

- 网关：8080
- 用户服务：8081
- 店铺服务：8082
- 订单服务：8083
- 支付服务：8084
- 促销服务：8085
- 采购服务：8086
- 退款服务：8087
- 补货服务：8088

## 快速开始

### 1. 数据库初始化

执行SQL脚本：
```bash
mysql -u root -p < sql/00_执行所有SQL脚本.sql
```

### 2. 启动Nacos

确保Nacos服务已启动（默认端口8848）

### 3. 启动后端服务

按顺序启动：
1. erp-list-gateway（网关）
2. erp-list-user-service（用户服务）
3. erp-list-seller-service（店铺服务）
4. 其他业务服务

### 4. 启动前端

```bash
cd erp-list-frontend
npm install
npm run dev
```

## 网关路由

- `/api/users/**` -> user-service
- `/api/sellers/**` -> seller-service
- `/api/orders/**` -> order-service
- `/api/payments/**` -> payment-service
- `/api/promotions/**` -> promotion-service
- `/api/coupons/**` -> promotion-service
- `/api/purchases/**` -> purchase-service
- `/api/refunds/**` -> refund-service
- `/api/replenishments/**` -> replenishment-service

## 数据隔离策略

- 默认按`zid`（公司级别）过滤数据
- 支持按`sid`（店铺级别）进一步过滤
- 前端提供店铺筛选下拉框

## 注意事项

1. 所有服务需要连接到Nacos（localhost:8848）
2. 数据库连接配置在application.yaml中
3. 不使用Seata，采用最终一致性
4. 密码加密建议使用BCryptPasswordEncoder（当前为简单实现）


