#!/bin/bash

###############################################################################
# QtKs 极致性能优化启动脚本
# 针对 ARM 设备（Orange Pi / Raspberry Pi）- 最大化性能
###############################################################################

# Qt 性能优化环境变量
export QT_QPA_PLATFORM=xcb

# 禁用所有调试输出
export QT_LOGGING_RULES="*=false"
export QT_DEBUG_PLUGINS=0

# 图形渲染优化
export QSG_RENDER_LOOP=basic           # 基础渲染循环
export QSG_RHI_BACKEND=opengl          # OpenGL 后端
export QT_XCB_GL_INTEGRATION=xcb_egl   # EGL 集成

# 图像优化
export QT_IMAGEIO_MAXALLOC=256         # 限制图像内存（256MB）

# QtQuick 性能优化
export QML_DISABLE_DISK_CACHE=0        # 启用 QML 磁盘缓存
export QML_FORCE_DISK_CACHE=1          # 强制使用磁盘缓存

# 禁用动画（如果仍然卡顿，取消下面注释）
# export QT_QUICK_FLICKABLE_WHEEL_DECELERATION=15000
# export QT_QUICK_FLICKABLE_MAX_VELOCITY=1000

# 线程优化
export QT_QPA_EGLFS_DISABLE_INPUT=0

# Python 优化
export PYTHONOPTIMIZE=1                # 启用 Python 优化
export PYTHONDONTWRITEBYTECODE=1       # 不写 .pyc 文件

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== QtKs 极致性能模式启动 ==="
echo "平台: Orange Pi / ARM"
echo "优化: 已禁用所有日志和调试输出"
echo ""

# 启动应用
if [ -d "$SCRIPT_DIR/venv" ]; then
    echo "使用虚拟环境启动..."
    source "$SCRIPT_DIR/venv/bin/activate"
    python -OO "$SCRIPT_DIR/main.py" 2>&1 | grep -v "QML\|Binding\|Warning" || true
elif [ -d "$SCRIPT_DIR/.venv" ]; then
    echo "使用 .venv 虚拟环境启动..."
    source "$SCRIPT_DIR/.venv/bin/activate"
    python -OO "$SCRIPT_DIR/main.py" 2>&1 | grep -v "QML\|Binding\|Warning" || true
else
    echo "错误: 未找到虚拟环境 (venv 或 .venv)"
    echo "请先创建虚拟环境:"
    echo "  python3 -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r requirements.txt"
    exit 1
fi
