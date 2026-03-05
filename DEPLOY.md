# ERP List 虚拟机部署指南

本文说明如何将 ERP List 前端与后端服务部署到一台或多台虚拟机（Linux）上。

## 一、架构概览

- **前端**：Vue3 + Vite 构建的静态资源，由 Nginx 提供；请求 `/api` 由 Nginx 反向代理到网关。
- **网关**：Spring Cloud Gateway（端口 8080），将 `/api/*` 按路径转发到各微服务（通过 Nacos 服务发现 `lb://服务名`）。
- **微服务**：用户、店铺、订单、商品、采购、退款、补货等，均注册到 Nacos，并连接 MySQL。
- **基础设施**：Nacos（服务注册与配置）、MySQL（各业务库）。

```
用户浏览器 → Nginx(80/443) → 静态前端
                        → /api → Gateway(8080) → Nacos(lb) → 各微服务(808x) → MySQL
```

## 二、环境准备

在虚拟机上安装：

| 软件 | 版本要求 | 说明 |
|------|----------|------|
| JDK | 11 | 后端运行 |
| Maven | 3.6+ | 后端构建（或本机构建后只传 jar） |
| Node.js | 16+ | 前端构建（或本机构建后只传 dist） |
| MySQL | 8.0 | 各服务数据库 |
| Nacos | 2.x | 服务注册与配置中心 |

当前配置中 Nacos 地址为 `39.105.104.224:8848`，MySQL 为 `39.105.104.224:3306`。若部署到新虚拟机，需将以下配置改为实际地址：

- 各服务 `bootstrap.yaml` 或 Nacos 中的 `spring.cloud.nacos.server-addr`
- 各服务 `application.yaml` 或 Nacos 中的 `spring.datasource.url`（及 username/password）

## 三、配置修改（部署到新 VM 时）

假设虚拟机 IP 为 `192.168.1.100`，Nacos 与 MySQL 均在该机或可访问的地址。

1. **Nacos**  
   - 在 Nacos 控制台或本机 `bootstrap.yaml` / `application.yaml` 中，将 `spring.cloud.nacos.server-addr` 改为 `192.168.1.100:8848`（或实际 Nacos 地址）。

2. **MySQL**  
   - 各服务的 `application.yaml`（或 Nacos 中对应配置）里，将 `spring.datasource.url` 中的主机改为实际 MySQL 地址，并保证库已创建（如 `erp_list_user` 等）、账号密码正确。

3. **前端接口地址**  
   - 生产环境前端已使用相对路径 `/api`（`.env.production` 中 `VITE_API_BASE` 为空），只要浏览器访问的页面与 Nginx 同源且 Nginx 将 `/api` 代理到网关即可，无需再改。

## 四、后端构建与运行

### 4.1 构建

在项目根目录（含父 `pom.xml` 的 `erp_list` 目录）执行：

```bash
mvn clean package -DskipTests
```

生成的 jar 位于各子模块的 `target/` 下，例如：

- `erp-list-gateway/target/erp-list-gateway.jar`
- `erp-list-user-service/target/erp-list-user-service.jar`
- `erp-list-seller-service/target/erp-list-seller-service.jar`
- 其他服务同理。

### 4.2 启动顺序

1. 启动 **Nacos**（若未常驻）。
2. 启动 **MySQL**，并确认各业务库与账号就绪。
3. 启动各**微服务**（顺序无强依赖，但建议先启动用户、店铺等基础服务）：
   ```bash
   java -jar erp-list-user-service/target/erp-list-user-service.jar
   java -jar erp-list-seller-service/target/erp-list-seller-service.jar
   java -jar erp-list-order-service/target/erp-list-order-service.jar
   java -jar erp-list-product-service/target/erp-list-product-service.jar
   java -jar erp-list-purchase-service/target/erp-list-purchase-service.jar
   java -jar erp-list-refund-service/target/erp-list-refund-service.jar
   java -jar erp-list-replenishment-service/target/erp-list-replenishment-service.jar
   ```
4. 最后启动**网关**（依赖 Nacos 中的服务列表）：
   ```bash
   java -jar erp-list-gateway/target/erp-list-gateway.jar
   ```

网关默认端口 **8080**。可用 `--server.port=8080` 覆盖，或通过 `application-xxx.yaml` / Nacos 配置。

**脚本快捷方式**（在项目根目录执行）：

- 一键构建后端+前端：`bash scripts/build-all.sh`
- 后台启动所有后端服务：`bash scripts/start-services.sh`（日志与 PID 在 `./logs`）
- 停止上述服务：`bash scripts/stop-services.sh`

### 4.3 后台运行与 systemd（可选）

使用 `nohup` 或 `systemd` 保持进程常驻，例如对网关：

```bash
nohup java -jar erp-list-gateway/target/erp-list-gateway.jar > gateway.log 2>&1 &
```

或为每个服务编写 `systemd` 的 `*.service` 文件，由 `systemctl start/enable` 管理。

## 五、前端构建与 Nginx 部署

### 5.1 构建前端

在 `erp-list-frontend` 目录下执行：

```bash
npm ci
npm run build
```

默认产出在 `dist/`。将整个 `dist` 目录上传到虚拟机的某个目录，例如 `/var/www/erp-list`。

### 5.2 Nginx 配置示例

在 Nginx 中为前端与 `/api` 配置一个 server，例如：

```nginx
server {
    listen 80;
    server_name your-domain-or-ip;

    root /var/www/erp-list;
    index index.html;
    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- 将 `root` 改为你放置 `dist` 内容的实际路径。
- 若网关不在本机，将 `proxy_pass` 改为 `http://网关IP:8080`。
- 若使用 HTTPS，可再增加 `listen 443 ssl` 与证书配置，并保持 `location /api` 代理到网关。

重载 Nginx：`nginx -s reload`。

## 六、验证

1. 浏览器访问 `http://虚拟机IP或域名`，应打开前端登录页。
2. 登录后请求会走 `/api` → 网关 → 用户服务等，可查看 Nacos 控制台确认服务已注册，网关 8080 端口可访问且无 502。

## 七、注意事项

- **防火墙**：开放 80（Nginx）、8080（若需直连网关）、8848（Nacos）、3306（MySQL，仅内网建议）。
- **密码与地址**：`application.yaml` 中数据库、Nacos 等含敏感信息，部署时建议用 Nacos 配置中心或环境变量覆盖，不要提交到代码库。
- **日志**：各服务日志路径在 `application.yaml` 的 `logging.file.path`（如 `logs/erp-list-user-service`），便于排查问题。

按以上步骤即可在虚拟机上完成从构建到对外提供访问的部署。
