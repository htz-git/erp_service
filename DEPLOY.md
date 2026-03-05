# 后端与前端部署到已有 Nacos/MySQL 的虚拟机（Docker）

在 **MySQL 和 Nacos 已部署好** 的虚拟机上，使用 **Docker** 部署本项目的后端服务与前端。Nacos、MySQL 连接地址与当前项目中 `application.yaml` 一致（默认 `39.105.104.224`），无需改成本机或 host 地址。

---

## 一、所需环境

### 1. 虚拟机已具备

| 项目 | 说明 |
|------|------|
| **MySQL** | 已安装并运行，且已创建各业务库：`erp_list_user`、`erp_list_seller`、`erp_list_order`、`erp_list_product`、`erp_list_purchase`、`erp_list_refund`、`erp_list_replenishment` |
| **Nacos** | 已安装并运行（端口 8848），地址与项目中配置一致（当前为 `39.105.104.224:8848`） |

### 2. 虚拟机需安装（用于构建与运行 Docker）

| 软件 | 版本要求 | 用途 |
|------|----------|------|
| **Docker** | 20.10+ | 运行后端与前端容器 |
| **Docker Compose** | 2.0+ | 编排服务 |
| **JDK** | 11 | 执行 `mvn package` 构建后端 jar |
| **Maven** | 3.6+ | 构建后端 jar |
| **Node.js** | 16+ | 构建前端（`npm run build`） |

若在本机或 CI 构建，则虚拟机只需 **Docker + Docker Compose**，将构建好的各模块 `target/*.jar` 与 `erp-list-frontend/dist` 上传到虚拟机即可。

### 3. 环境校验与安装

部署前可在虚拟机上先执行以下命令，确认各软件是否已存在及版本是否满足要求。

**校验是否已安装且版本满足要求**（在虚拟机终端执行）：

```bash
# Docker 需 20.10+
docker --version

# Docker Compose 需 2.0+（插件形式为 docker compose，独立命令为 docker-compose）
docker compose version
# 或
docker-compose --version

# JDK 需 11（输出应包含 "11"）
java -version
javac -version

# Maven 需 3.6+
mvn -version

# Node.js 需 16+，npm 随 Node 安装
node -v
npm -v
```

任一命令报「未找到」或版本低于要求时，需先安装或升级。以下为 **Ubuntu/Debian** 下的安装命令（需 root 或 sudo）。

**安装命令（Ubuntu / Debian）**：

```bash
# 更新包索引
sudo apt-get update

# Docker（官方推荐方式：使用 Docker 仓库）
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 若希望当前用户直接运行 docker（免 sudo），可执行：
# sudo usermod -aG docker $USER
# 然后重新登录

# JDK 11
sudo apt-get install -y openjdk-11-jdk

# Maven
sudo apt-get install -y maven

# Node.js 16+（使用 NodeSource 源，以 20.x 为例）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**CentOS / RHEL 示例**（若为 dnf 系统可将 `yum` 改为 `dnf`；已安装 Docker 时可只执行 JDK、Maven、Node 三块）：

```bash
# Docker（若未安装）
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker && systemctl enable docker

# JDK 11
yum install -y java-11-openjdk-devel

# Maven
yum install -y maven

# Node.js 16+（NodeSource，以 20.x 为例）
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs
```

仅安装 JDK、Maven、Node（Docker 已有时可直接复制）：

```bash
yum install -y java-11-openjdk-devel
yum install -y maven
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs
```

安装完成后再次执行上面的「校验是否已安装」命令，确认版本符合要求后再进行 **二、部署流程**。

---

## 二、部署流程

### 步骤 1：在项目根目录构建后端

在 **erp_list** 项目根目录执行：

```bash
mvn clean package -DskipTests
```

**校验后端 jar 是否全部生成**（缺少任一则后续 Docker 构建会失败）：

```bash
# 检查 8 个 jar 是否都存在（在项目根目录执行）
required_jars=(
  erp-list-user-service/target/erp-list-user-service.jar
  erp-list-seller-service/target/erp-list-seller-service.jar
  erp-list-order-service/target/erp-list-order-service.jar
  erp-list-product-service/target/erp-list-product-service.jar
  erp-list-purchase-service/target/erp-list-purchase-service.jar
  erp-list-refund-service/target/erp-list-refund-service.jar
  erp-list-replenishment-service/target/erp-list-replenishment-service.jar
  erp-list-gateway/target/erp-list-gateway.jar
)
missing=0
for j in "${required_jars[@]}"; do
  if [ ! -f "$j" ]; then
    echo "缺失: $j"
    missing=1
  fi
done
if [ $missing -eq 0 ]; then
  echo "所有后端 jar 已就绪"
fi
```

或逐一手动检查（Linux/macOS 用 `ls -la`，Windows PowerShell 用 `Get-ChildItem`）：

```bash
# Linux / macOS
ls -la erp-list-user-service/target/erp-list-user-service.jar
ls -la erp-list-seller-service/target/erp-list-seller-service.jar
# ... 其余同理
```

```powershell
# Windows PowerShell（在项目根目录执行）
Get-ChildItem erp-list-user-service\target\erp-list-user-service.jar
Get-ChildItem erp-list-seller-service\target\erp-list-seller-service.jar
Get-ChildItem erp-list-order-service\target\erp-list-order-service.jar
Get-ChildItem erp-list-product-service\target\erp-list-product-service.jar
Get-ChildItem erp-list-purchase-service\target\erp-list-purchase-service.jar
Get-ChildItem erp-list-refund-service\target\erp-list-refund-service.jar
Get-ChildItem erp-list-replenishment-service\target\erp-list-replenishment-service.jar
Get-ChildItem erp-list-gateway\target\erp-list-gateway.jar
```

或一次性检查（PowerShell）：

```powershell
$jars = @(
  "erp-list-user-service\target\erp-list-user-service.jar",
  "erp-list-seller-service\target\erp-list-seller-service.jar",
  "erp-list-order-service\target\erp-list-order-service.jar",
  "erp-list-product-service\target\erp-list-product-service.jar",
  "erp-list-purchase-service\target\erp-list-purchase-service.jar",
  "erp-list-refund-service\target\erp-list-refund-service.jar",
  "erp-list-replenishment-service\target\erp-list-replenishment-service.jar",
  "erp-list-gateway\target\erp-list-gateway.jar"
)
$missing = 0
foreach ($j in $jars) { if (-not (Test-Path $j)) { Write-Host "缺失: $j"; $missing = 1 } }
if ($missing -eq 0) { Write-Host "所有后端 jar 已就绪" }
```

### 步骤 2：在项目根目录构建前端

仍在 **erp_list** 项目根目录执行：

```bash
cd erp-list-frontend && npm ci && npm run build && cd ..
```

**校验前端产物是否存在**：

```bash
# 检查 dist 目录及入口文件（在项目根目录执行）
if [ -d "erp-list-frontend/dist" ] && [ -f "erp-list-frontend/dist/index.html" ]; then
  echo "前端 dist 已就绪"
else
  echo "请确认 erp-list-frontend/dist 已生成且包含 index.html"
  exit 1
fi
```

或手动检查（Linux/macOS 用 `ls -la`，Windows PowerShell 用 `Get-ChildItem`）：

```bash
# Linux / macOS
ls -la erp-list-frontend/dist/
ls -la erp-list-frontend/dist/index.html
```

```powershell
# Windows PowerShell
Get-ChildItem erp-list-frontend\dist
Test-Path erp-list-frontend\dist\index.html
```

### 步骤 3：将项目上传到虚拟机（若在本地构建）

若构建是在本机完成的，将整个 **erp_list** 目录（含各模块 `target/`、`erp-list-frontend/dist/`）上传到已部署好 Nacos、MySQL 的虚拟机，例如 `/opt/erp_list`。上传后可在虚拟机再次执行上述校验命令确认 jar 与 dist 存在。

### 步骤 4：配置环境变量

在虚拟机上的项目根目录执行：

```bash
cp .env.example .env
```

`.env.example` 中已按项目当前配置写好 Nacos、MySQL 地址（`39.105.104.224`），一般无需改。若 MySQL 密码不是 `root`，可编辑 `.env` 修改 `MYSQL_PASSWORD`。若 Nacos 或 MySQL 不在该 IP，则修改 `NACOS_SERVER`、`MYSQL_HOST` 为实际地址。

### 步骤 5：使用 Docker Compose 启动

在虚拟机上的项目根目录（包含 `docker-compose.yml` 的目录）执行：

```bash
docker compose up -d
```

如需重新构建镜像（例如重新执行过步骤 1、2 后）：

```bash
docker compose up -d --build
```

- **前端**：浏览器访问 `http://虚拟机IP`（端口 80，容器内 Nginx 将 `/api` 转发到网关）
- **后端**：7 个微服务 + 网关在容器内运行，通过 `.env`（默认 `39.105.104.224`）连接 Nacos、MySQL

### 步骤 6：验证

1. 浏览器打开 `http://虚拟机IP`，应出现前端登录页。
2. 登录后能正常使用（请求走 `/api` → 网关 → 各微服务）。
3. 在 Nacos 控制台可看到各服务已注册。

---

## 三、常用命令

| 操作 | 命令 |
|------|------|
| 停止所有服务 | `docker compose down` |
| 查看日志 | `docker compose logs -f` 或 `docker compose logs -f gateway`（按服务名） |
| 重启 | `docker compose restart` 或 `docker compose restart gateway` |

---

## 四、说明

- Nacos、MySQL 连接地址来自 `.env`，默认与项目中 `application.yaml` 一致（`39.105.104.224:8848`、`39.105.104.224:3306`），无需使用本机或 host 地址。
- 代码或配置变更后，若重新构建了 jar 或前端，需重新执行 **步骤 1、2**（及步骤 3 若在本地构建），再在虚拟机执行 `docker compose up -d --build` 重新构建镜像并启动。
