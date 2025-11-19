#!/bin/bash
# QtKs 启动脚本

# 设置显示平台（根据环境自动选择）
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    echo "检测到显示环境"
else
    echo "无显示环境，使用 offscreen 模式"
    export QT_QPA_PLATFORM=offscreen
fi

# 设置 Python 路径
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# 运行应用
echo "启动 QtKs..."
python3 main.py
