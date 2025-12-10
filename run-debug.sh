#!/bin/bash

###############################################################################
# QtKs 调试启动脚本 - 显示所有输出以便排查问题
###############################################################################

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== QtKs 调试模式启动 ==="
echo "显示所有输出以排查问题"
echo ""

# 启动应用 - 显示所有输出
if [ -d "$SCRIPT_DIR/.venv" ]; then
    echo "使用 .venv 虚拟环境启动..."
    source "$SCRIPT_DIR/.venv/bin/activate"
    python "$SCRIPT_DIR/main.py" 2>&1
else
    echo "错误: 未找到 .venv 虚拟环境"
    echo "请先创建虚拟环境:"
    echo "  python3 -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r requirements.txt"
    exit 1
fi