#!/bin/bash

###############################################################################
# QtKs 性能优化启动脚本
# 针对 ARM 设备（Orange Pi / Raspberry Pi）优化
###############################################################################

# Qt 性能优化环境变量
export QT_QPA_PLATFORM=xcb

# 禁用 Qt 调试输出
export QT_LOGGING_RULES="*.debug=false;qt.qml.*.debug=false"

# 图形渲染优化
export QSG_RENDER_LOOP=basic           # 使用基础渲染循环（减少线程开销）
export QSG_RHI_BACKEND=opengl          # 使用 OpenGL 后端
export QT_XCB_GL_INTEGRATION=xcb_egl   # 使用 EGL 集成

# 帧率限制 - 30fps 适合 ARM 设备
export QSG_RENDER_TARGET_FPS=30        # 目标帧率 30fps

# 图像优化
export QT_IMAGEIO_MAXALLOC=512         # 限制图像内存分配（MB）

# 字体渲染优化（禁用抗锯齿以提升性能）
# export QT_FONT_DPI=96                # 固定 DPI
# export QT_AUTO_SCREEN_SCALE_FACTOR=0 # 禁用自动缩放

# QtQuick 性能优化
export QML_DISABLE_DISK_CACHE=0        # 启用 QML 磁盘缓存
export QML_FORCE_DISK_CACHE=1          # 强制使用磁盘缓存

# 线程优化
export QT_QPA_EGLFS_DISABLE_INPUT=0

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 启动应用
if [ -d "$SCRIPT_DIR/venv" ]; then
    echo "使用虚拟环境启动..."
    source "$SCRIPT_DIR/venv/bin/activate"
    python "$SCRIPT_DIR/main.py"
elif [ -d "$SCRIPT_DIR/.venv" ]; then
    echo "使用 .venv 虚拟环境启动..."
    source "$SCRIPT_DIR/.venv/bin/activate"
    python "$SCRIPT_DIR/main.py"
else
    echo "错误: 未找到虚拟环境 (venv 或 .venv)"
    echo "请先创建虚拟环境:"
    echo "  python3 -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r requirements.txt"
    exit 1
fi
