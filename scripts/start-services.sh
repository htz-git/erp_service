#!/bin/bash
# 在项目根目录（erp_list）下执行，启动所有后端服务（需先 mvn package）
# 用法: ./scripts/start-services.sh
# 或: bash scripts/start-services.sh

set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

JAVA_OPTS="${JAVA_OPTS:--Xms256m -Xmx512m}"
LOG_DIR="${LOG_DIR:-./logs}"
mkdir -p "$LOG_DIR"

start_jar() {
  local name="$1"
  local jar="$2"
  if [ ! -f "$jar" ]; then
    echo "跳过 $name：未找到 $jar，请先执行 mvn clean package -DskipTests"
    return 0
  fi
  echo "启动 $name ..."
  nohup java $JAVA_OPTS -jar "$jar" >> "$LOG_DIR/${name}.log" 2>&1 &
  echo $! > "$LOG_DIR/${name}.pid"
}

# 微服务（先于网关启动）
start_jar erp-list-user-service         erp-list-user-service/target/erp-list-user-service.jar
start_jar erp-list-seller-service       erp-list-seller-service/target/erp-list-seller-service.jar
start_jar erp-list-order-service       erp-list-order-service/target/erp-list-order-service.jar
start_jar erp-list-product-service     erp-list-product-service/target/erp-list-product-service.jar
start_jar erp-list-purchase-service     erp-list-purchase-service/target/erp-list-purchase-service.jar
start_jar erp-list-refund-service      erp-list-refund-service/target/erp-list-refund-service.jar
start_jar erp-list-replenishment-service erp-list-replenishment-service/target/erp-list-replenishment-service.jar

sleep 3
# 网关
start_jar erp-list-gateway              erp-list-gateway/target/erp-list-gateway.jar

echo "所有服务已在后台启动，PID 与日志见 $LOG_DIR"
echo "停止方式: kill \$(cat $LOG_DIR/*.pid)"
