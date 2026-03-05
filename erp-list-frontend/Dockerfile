# 前端：先构建再打包进 nginx（构建阶段在宿主机或 CI 完成，此处仅拷贝 dist）
# 构建：在 erp-list-frontend 目录执行 npm run build，再在项目根目录执行 docker build
FROM nginx:alpine
COPY dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
