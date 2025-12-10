#!/bin/bash

###############################################################################
# QtKs 软件渲染模式启动脚本
# 适用于 GPU 驱动有问题的设备
###############################################################################

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== QtKs 软件渲染模式启动 ==="
echo "平台: Orange Pi 3B"
echo "渲染: 软件渲染 (兼容性最高)"
echo "注意: 性能会降低，但稳定性更好"
echo ""

# 强制使用软件渲染
export LIBGL_ALWAYS_SOFTWARE=1
export LIBGL_DRI3_DISABLE=1

# Qt 环境变量
export QT_QPA_PLATFORM=xcb

# 图形渲染优化 - 软件渲染模式
export QSG_RENDER_LOOP=basic                    # 基础渲染循环
export QSG_RHI_BACKEND=software                 # 强制软件渲染
export QT_XCB_GL_INTEGRATION=glx                # 使用 glx

# 禁用图形加速功能
export QT_QUICK_USE_FBO=0                      # 禁用 FBO
export QT_QUICK_NO_DEPTH_BUFFER=1               # 禁用深度缓冲
export QT_QUICK_MULTISAMPLE=0                   # 禁用多重采样
export QT_QUICK_NO_SPRITES=1                    # 禁用精灵

# 禁用高级渲染特性
export QT_QUICK_USE_ALPHAMAP=0                  # 禁用透明度映射
export QT_QUICK_DISABLE_SEAMLESS=1              # 禁用无缝渲染

# 禁用调试输出
export QT_LOGGING_RULES="*.debug=false;qt.qml.*.debug=false"

# 图像和缓存优化
export QT_IMAGEIO_MAXALLOC=128                 # 减少图像内存
export QML_DISABLE_DISK_CACHE=0                 # 启用 QML 磁盘缓存
export QML_FORCE_DISK_CACHE=1                   # 强制使用磁盘缓存

# Python 优化
export PYTHONOPTIMIZE=1
export PYTHONDONTWRITEBYTECODE=1

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