# ERP List Frontend

## 技术栈

- Vue 3
- Element Plus
- Vue Router
- Pinia（状态管理）
- Axios
- Vite

## 快速开始

### 安装依赖

```bash
npm install
```

### 开发

```bash
npm run dev
```

### 构建

```bash
npm run build
```

### 预览

```bash
npm run preview
```

## 项目结构

```
src/
├── api/              # API接口
├── layout/           # 布局组件
├── router/           # 路由配置
├── store/            # Pinia状态管理
├── utils/            # 工具类
└── views/            # 页面组件
    ├── Login.vue     # 登录页
    ├── Dashboard.vue # 首页
    ├── user/         # 用户管理
    ├── seller/       # 店铺管理
    ├── order/        # 订单管理
    ├── payment/       # 支付管理
    ├── purchase/     # 采购管理
    ├── refund/       # 退款管理
    ├── coupon/       # 优惠券管理
    └── replenishment/ # 补货管理
```

## 功能说明

### 多租户支持

- 支持按公司（zid）和店铺（sid）进行数据过滤
- 前端提供店铺筛选下拉框
- 用户登录后自动获取所属公司信息

### 路由守卫

- 未登录用户自动跳转到登录页
- 已登录用户访问登录页自动跳转到首页

### 请求拦截

- 自动添加Authorization请求头
- 401错误自动跳转到登录页


