# ERP List 微服务架构项目

## 项目简介

ERP List是一个基于Spring Cloud微服务架构的跨境电商管理系统，参考了erp项目的业务功能，使用hmall项目的微服务架构配置。

---

## 如何启动服务（快速开始）

### 前置条件

- **JDK 8+**、**Maven**、**Node.js**（前端）
- **Nacos** 已启动（默认 `localhost:8848`）
- **MySQL** 已就绪，并执行过数据库脚本（见下方「数据库初始化」）

### 启动顺序（简要）

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1 | 启动 **Nacos** | 端口 8848，所有服务依赖 |
| 2 | **数据库初始化** | 执行 `sql/00_执行所有SQL脚本.sql` |
| 3 | 启动 **网关** | `cd erp-list-gateway && mvn spring-boot:run`，端口 8080 |
| 4 | 启动各 **微服务** | 用户(8081)、店铺(8082)、订单(8083) 等，见下方详细命令 |
| 5 | （可选）启动 **LSTM 预测服务** | Python，端口 5000，见「LSTM 服务」 |
| 6 | 启动 **前端** | `cd erp-list-frontend && npm i && npm run dev` |

### 消除 Python 导入报错（必读：使用 LSTM 或编辑 Python 时）

本项目以 **Java 为主**，仓库根目录未配置 Python 解释器，因此 **`lstm-forecast-service` 下的 `flask`、`numpy`、`tensorflow` 等导入会全部报错**。按下面任选一种方式即可修复：

**方式一：在 IDE 中选择 Python 解释器（推荐）**

1. 在 **`lstm-forecast-service`** 目录下创建并激活虚拟环境（若尚未创建）：
   ```bash
   cd lstm-forecast-service
   python -m venv venv
   # Windows:
   venv\Scripts\activate
   # Mac/Linux:
   # source venv/bin/activate
   pip install -r requirements.txt
   ```
2. 在 **Cursor / VS Code** 中：`Ctrl+Shift+P`（Mac：`Cmd+Shift+P`）→ 输入 **「Python: Select Interpreter」** → 选择：
   - **Windows**：`lstm-forecast-service\venv\Scripts\python.exe`
   - **Mac/Linux**：`lstm-forecast-service/venv/bin/python`

**方式二：让工作区默认使用该解释器**

将项目根目录下的 **`vscode-settings-example.json`** 内容复制到 **`.vscode/settings.json`**（需自行创建 `.vscode` 目录；该目录被 .gitignore，仅本地生效）。  
Mac/Linux 用户请将示例中的 `Scripts/python.exe` 改为 `bin/python`。

完成上述任一步骤后，`lstm-forecast-service` 下的 Python 文件不应再出现第三方库导入报错。

---

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
├── erp-list-replenishment-service/ # 补货服务（补货单、LSTM 补货建议）
├── lstm-forecast-service/    # LSTM 补货预测服务（Python，供补货服务调用）
├── sql/                       # SQL脚本
├── erp-list-frontend/         # 前端项目
└── vscode-settings-example.json  # IDE Python 解释器示例配置
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

| 服务 | 端口 |
|------|------|
| 网关 | 8080 |
| 用户服务 | 8081 |
| 店铺服务 | 8082 |
| 订单服务 | 8083 |
| 支付服务 | 8084 |
| 促销服务 | 8085 |
| 采购服务 | 8086 |
| 退款服务 | 8087 |
| 补货服务 | 8088 |
| **LSTM 预测服务（Python）** | **5000** |

## 启动服务（详细步骤）

### 1. 数据库初始化

执行 SQL 脚本（按需修改库名/账号）：

```bash
mysql -u root -p < sql/00_执行所有SQL脚本.sql
```

### 2. 启动 Nacos

确保 Nacos 已启动（默认端口 8848）。

### 3. 启动后端 Java 服务

在项目根目录 `erp_list` 下，按以下顺序启动（可多开终端或 IDE 运行各模块的 `*Application` 主类）：

```bash
# 1）网关（必须最先）
cd erp-list-gateway && mvn spring-boot:run

# 2）用户服务
cd erp-list-user-service && mvn spring-boot:run

# 3）店铺服务
cd erp-list-seller-service && mvn spring-boot:run

# 4）订单服务（补货建议依赖其销售时序接口）
cd erp-list-order-service && mvn spring-boot:run

# 5）补货服务（可选，依赖订单服务；若需补货建议还需启动 LSTM 服务）
cd erp-list-replenishment-service && mvn spring-boot:run

# 6）其余服务按需启动：支付、促销、采购、退款等
# cd erp-list-payment-service && mvn spring-boot:run
# cd erp-list-promotion-service && mvn spring-boot:run
# ...
```

### 4. 启动 LSTM 补货预测服务（Python，可选）

补货建议接口（`GET /replenishments/suggestions`）会调用本服务；若不启动，补货建议将返回空列表。

- **Python**：建议 3.8 或 3.9（与 TensorFlow 兼容较好）。
- **依赖安装与运行**（在 `lstm-forecast-service` 下）：

```bash
cd lstm-forecast-service
python -m venv venv
# Windows:
venv\Scripts\activate
# Mac/Linux:
# source venv/bin/activate
pip install -r requirements.txt
python app.py
```

默认监听 **5000** 端口；补货服务中 `lstm.forecast.service-url` 需指向该地址（默认 `http://localhost:5000`）。  
**IDE 中 Python 导入报错**：见上文「消除 Python 导入报错」一节。

### 5. 启动前端

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


