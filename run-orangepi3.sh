#!/bin/bash

###############################################################################
# QtKs Orange Pi 3B 专用优化启动脚本
# 针对 Orange Pi 3B 的 Rockchip GPU 问题优化
###############################################################################

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== QtKs Orange Pi 3B 优化模式启动 ==="
echo "平台: Orange Pi 3B"
echo "GPU: Rockchip (优化模式)"
echo ""

# Orange Pi 3B 专用环境变量
export QT_QPA_PLATFORM=xcb

# 图形渲染优化 - 针对 Rockchip GPU
export QSG_RENDER_LOOP=basic                    # 基础渲染循环，兼容性更好
export QSG_RHI_BACKEND=opengl                   # 使用 OpenGL 后端
export QT_XCB_GL_INTEGRATION=glx                # 使用 glx 而不是 xcb_egl
export QT_OPENGL_LOGGING=1                      # 启用 OpenGL 日志

# 禁用可能导致 Rockchip GPU 问题的高级功能
export QT_QUICK_MULTISAMPLE=0                   # 禁用多重采样
export QT_QUICK_USE_FBO=0                      # 禁用 FBO（Frame Buffer Object）
export QT_QUICK_NO_DEPTH_BUFFER=1               # 禁用深度缓冲

# 禁用 Qt 调试输出
export QT_LOGGING_RULES="*.debug=false;qt.qml.*.debug=false"

# 图像优化
export QT_IMAGEIO_MAXALLOC=256                 # 限制图像内存

# QML 缓存
export QML_DISABLE_DISK_CACHE=0                 # 启用 QML 磁盘缓存
export QML_FORCE_DISK_CACHE=1                   # 强制使用磁盘缓存

# Python 优化
export PYTHONOPTIMIZE=1
export PYTHONDONTWRITEBYTECODE=1

# 如果有，使用 Mesa 软件渲染（作为备选方案）
# export LIBGL_ALWAYS_SOFTWARE=1

# 启动应用
if [ -d "$SCRIPT_DIR/.venv" ]; then
    echo "使用 .venv 虚拟环境启动..."
    source "$SCRIPT_DIR/.venv/bin/activate"
    python "$SCRIPT_DIR/main.py"
else
    echo "错误: 未找到 .venv 虚拟环境"
    echo "请先创建虚拟环境:"
    echo "  python3 -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r requirements.txt"
    exit 1
fi