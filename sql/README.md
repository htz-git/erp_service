# ERP微服务架构 - SQL脚本说明

## 文件说明

### 00_执行所有SQL脚本.sql
- 一键执行所有SQL脚本的主脚本
- 按顺序执行所有数据库和表结构创建

### 01_创建数据库.sql
- 创建所有微服务所需的数据库
- 包括：erp_list_user, erp_list_seller, erp_list_order, erp_list_payment, erp_list_promotion, erp_list_purchase, erp_list_refund, erp_list_replenishment

### 02_用户服务表结构.sql
- 用户服务数据库表结构
- 包括：user（包含zid字段）、role、permission、user_role、role_permission

### 03_店铺服务表结构.sql
- 店铺服务数据库表结构
- 包括：seller表（id字段就是sid）

### 04_订单服务表结构.sql
- 订单服务数据库表结构
- 包括：order（包含zid和sid字段）、order_item（包含zid和sid字段）、order_status_log

### 05_支付服务表结构.sql
- 支付服务数据库表结构
- 包括：payment（包含zid和sid字段）、payment_method、payment_flow

### 06_促销服务表结构.sql
- 促销服务数据库表结构
- 包括：promotion、coupon、user_coupon、promotion_rule

### 07_采购服务表结构.sql
- 采购服务数据库表结构
- 包括：supplier、purchase_order（包含zid和sid字段）、purchase_item（包含zid和sid字段）、purchase_status_log

### 08_退款服务表结构.sql
- 退款服务数据库表结构
- 包括：refund_application（包含zid和sid字段）、refund_record、refund_reason

### 09_补货服务表结构.sql
- 补货服务数据库表结构
- 包括：replenishment_order（包含zid和sid字段）、replenishment_item（包含zid和sid字段）、inventory_alert、replenishment_plan

## 执行方式

### 方式一：使用MySQL客户端执行

```bash
# 1. 登录MySQL
mysql -u root -p

# 2. 执行主脚本
source E:/erp_list/sql/00_执行所有SQL脚本.sql

# 或者逐个执行
source E:/erp_list/sql/01_创建数据库.sql
source E:/erp_list/sql/02_用户服务表结构.sql
# ... 其他脚本
```

### 方式二：使用命令行执行

```bash
# Windows
mysql -u root -p < sql\00_执行所有SQL脚本.sql

# Linux/Mac
mysql -u root -p < sql/00_执行所有SQL脚本.sql
```

## 关键设计说明

### 多租户字段
- **zid**：VARCHAR(50)，公司ID
- **sid**：BIGINT，店铺ID，引用seller表的id字段

### 需要zid和sid字段的表
- order、order_item
- payment
- purchase_order、purchase_item
- refund_application
- replenishment_order、replenishment_item

### 索引设计
- 所有包含zid的表都创建了`idx_zid`索引
- 所有包含sid的表都创建了`idx_sid`索引
- 对于经常同时按zid和sid查询的表，创建了`idx_zid_sid`复合索引

## 注意事项

1. **执行顺序**：必须按照文件编号顺序执行
2. **数据库权限**：确保MySQL用户有创建数据库和表的权限
3. **字符集**：所有数据库和表都使用 utf8mb4 字符集
4. **初始数据**：部分脚本包含初始数据（如支付方式、退款原因），可根据需要修改


