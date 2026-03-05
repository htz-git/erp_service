#!/bin/bash
# 在项目根目录（erp_list）下执行：构建后端 + 前端
# 用法: ./scripts/build-all.sh

set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== 构建后端 ==="
mvn clean package -DskipTests

echo "=== 构建前端 ==="
if [ -d erp-list-frontend ]; then
  cd erp-list-frontend
  npm ci
  npm run build
  echo "前端产物: erp-list-frontend/dist"
  cd "$ROOT"
else
  echo "未找到 erp-list-frontend 目录，跳过前端构建"
fi

echo "=== 构建完成 ==="
echo "后端 jar: 各模块 target/*.jar"
echo "前端静态: erp-list-frontend/dist（可部署到 Nginx）"
