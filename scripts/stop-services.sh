#!/bin/bash
# 停止由 start-services.sh 启动的后端服务
# 用法: ./scripts/stop-services.sh

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${LOG_DIR:-$ROOT/logs}"

for pidfile in "$LOG_DIR"/*.pid; do
  [ -f "$pidfile" ] || continue
  pid=$(cat "$pidfile")
  name=$(basename "$pidfile" .pid)
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" && echo "已停止 $name (PID $pid)"
  fi
  rm -f "$pidfile"
done
