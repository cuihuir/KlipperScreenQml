#!/bin/bash

###############################################################################
# QtKs 性能监控脚本
# 实时监控 CPU、内存、线程数
###############################################################################

echo "=== QtKs 性能监控 ==="
echo "按 Ctrl+C 退出"
echo ""

# 查找 QtKs 进程
find_qtks_pid() {
    pgrep -f "python.*main.py" | head -1
}

while true; do
    PID=$(find_qtks_pid)

    if [ -z "$PID" ]; then
        echo "[$(date +%H:%M:%S)] QtKs 未运行"
        sleep 2
        continue
    fi

    # 获取 CPU 和内存
    CPU=$(ps -p $PID -o %cpu= | tr -d ' ')
    MEM=$(ps -p $PID -o %mem= | tr -d ' ')
    RSS=$(ps -p $PID -o rss= | tr -d ' ')
    THREADS=$(ps -p $PID -o nlwp= | tr -d ' ')

    # 转换 RSS 到 MB
    RSS_MB=$((RSS / 1024))

    # 显示信息
    printf "\r[%s] PID: %5s | CPU: %5s%% | MEM: %4s%% (%4s MB) | Threads: %2s" \
        "$(date +%H:%M:%S)" "$PID" "$CPU" "$MEM" "$RSS_MB" "$THREADS"

    sleep 1
done
