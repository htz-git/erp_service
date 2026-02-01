# Git 操作指南 - 将 erp_list 项目上传到 GitHub

## 前置准备

1. **确保已安装 Git**
   ```bash
   git --version
   ```

2. **配置 Git 用户信息**（如果还没配置）
   ```bash
   git config --global user.name "你的名字"
   git config --global user.email "你的邮箱"
   ```

3. **在 GitHub 上创建新仓库**
   - 登录 GitHub
   - 点击右上角 "+" -> "New repository"
   - 仓库名称：`erp_list`（或你喜欢的名称）
   - 选择 Public 或 Private
   - **不要**勾选 "Initialize this repository with a README"
   - 点击 "Create repository"

## 操作步骤

### 步骤 1：进入项目目录
```bash
cd E:\erp_list
```

### 步骤 2：初始化 Git 仓库
```bash
git init
```

### 步骤 3：添加所有文件到暂存区
```bash
git add .
```

### 步骤 4：创建初始提交
```bash
git commit -m "初始提交：创建 erp_list 微服务项目"
```

### 步骤 5：添加远程仓库地址
将 `YOUR_USERNAME` 替换为你的 GitHub 用户名，`YOUR_REPO_NAME` 替换为你的仓库名：
```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

例如：
```bash
git remote add origin https://github.com/yourusername/erp_list.git
```

### 步骤 6：重命名主分支为 main（如果默认是 master）
```bash
git branch -M main
```

### 步骤 7：推送到 GitHub
```bash
git push -u origin main
```

如果提示需要认证，GitHub 现在要求使用 Personal Access Token（PAT）而不是密码：
- 访问：https://github.com/settings/tokens
- 点击 "Generate new token" -> "Generate new token (classic)"
- 设置过期时间和权限（至少需要 `repo` 权限）
- 复制生成的 token
- 在推送时，用户名输入你的 GitHub 用户名，密码输入刚才复制的 token

## 后续操作

### 查看远程仓库
```bash
git remote -v
```

### 查看提交历史
```bash
git log --oneline
```

### 查看当前状态
```bash
git status
```

### 后续提交和推送
```bash
# 1. 添加修改的文件
git add .

# 2. 提交
git commit -m "提交说明"

# 3. 推送到 GitHub
git push
```

## 常见问题

### 1. 如果远程仓库已存在文件（比如 README）
先拉取远程内容：
```bash
git pull origin main --allow-unrelated-histories
```
解决可能的冲突后，再推送：
```bash
git push -u origin main
```

### 2. 如果推送时提示认证失败
- 确保使用 Personal Access Token 而不是密码
- 检查 token 是否有 `repo` 权限
- 如果使用 SSH，需要配置 SSH 密钥

### 3. 如果忘记添加 .gitignore
```bash
# 删除已跟踪的文件（但保留本地文件）
git rm -r --cached .
git add .
git commit -m "更新 .gitignore"
git push
```

## 使用 SSH 方式（可选）

如果你配置了 SSH 密钥，可以使用 SSH 地址：

```bash
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

## 验证

推送成功后，访问你的 GitHub 仓库页面，应该能看到所有项目文件。

