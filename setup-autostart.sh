#!/bin/bash

###############################################################################
# QtKs 开机自启动配置脚本
# 用于快速配置 systemd 服务
#
# ⚠️  状态：未验证
# 本脚本尚未在实际环境中完整验证，使用前请谨慎
# 验证完成后请更新 CLAUDE.md 文档
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 获取当前脚本目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_USER=$(whoami)
PYTHON_PATH="$SCRIPT_DIR/venv/bin/python"
MAIN_PY_PATH="$SCRIPT_DIR/main.py"

echo ""
echo "=========================================="
echo "    QtKs 开机自启动配置"
echo "=========================================="
echo ""

# 检查必要文件
if [ ! -f "$MAIN_PY_PATH" ]; then
    log_error "找不到 main.py，请确认在正确的目录中运行此脚本"
    exit 1
fi

if [ ! -f "$PYTHON_PATH" ]; then
    log_error "找不到虚拟环境，请先运行 install.sh 或手动创建虚拟环境"
    exit 1
fi

log_info "安装目录: $SCRIPT_DIR"
log_info "当前用户: $CURRENT_USER"
log_info "Python 路径: $PYTHON_PATH"

# 选择 Qt 平台
echo ""
log_info "选择 Qt 平台插件:"
echo "1) xcb (X11, 推荐用于桌面环境)"
echo "2) wayland (如果系统支持 Wayland)"
echo "3) eglfs (直接渲染到 framebuffer，无桌面环境)"
echo ""
read -p "请选择 [1-3] (默认: 1): " platform_choice

case ${platform_choice:-1} in
    1) QT_PLATFORM="xcb" ;;
    2) QT_PLATFORM="wayland" ;;
    3) QT_PLATFORM="eglfs" ;;
    *) QT_PLATFORM="xcb" ;;
esac

log_info "选择的平台: $QT_PLATFORM"

# 生成服务文件
SERVICE_FILE="/tmp/qtks.service"

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=QtKs 3D Printer Interface
After=network.target graphical.target
Wants=graphical.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$SCRIPT_DIR
Environment="DISPLAY=:0"
Environment="QT_QPA_PLATFORM=$QT_PLATFORM"
Environment="PATH=$SCRIPT_DIR/venv/bin:/usr/local/bin:/usr/bin:/bin"

# ===== 性能优化环境变量 =====
Environment="QT_LOGGING_RULES=*.debug=false;qt.qml.*.debug=false"
Environment="QSG_RENDER_LOOP=basic"
Environment="QSG_RHI_BACKEND=opengl"
Environment="QT_XCB_GL_INTEGRATION=xcb_egl"
Environment="QT_IMAGEIO_MAXALLOC=512"
Environment="QML_DISABLE_DISK_CACHE=0"
Environment="QML_FORCE_DISK_CACHE=1"

ExecStart=$PYTHON_PATH $MAIN_PY_PATH
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=graphical.target
EOF

# 安装服务
log_info "安装 systemd 服务..."
sudo mv "$SERVICE_FILE" /etc/systemd/system/qtks.service
sudo chmod 644 /etc/systemd/system/qtks.service

# 重新加载 systemd
log_info "重新加载 systemd 配置..."
sudo systemctl daemon-reload

log_success "服务文件已安装: /etc/systemd/system/qtks.service"

# 询问是否启用
echo ""
read -p "是否启用开机自启动? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo systemctl enable qtks.service
    log_success "已启用开机自启动"
else
    log_info "未启用开机自启动，可以稍后使用: sudo systemctl enable qtks.service"
fi

# 询问是否立即启动
echo ""
read -p "是否立即启动服务? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    log_info "停止旧服务（如果正在运行）..."
    sudo systemctl stop qtks.service 2>/dev/null || true

    log_info "启动服务..."
    sudo systemctl start qtks.service

    sleep 2

    log_info "检查服务状态..."
    if sudo systemctl is-active --quiet qtks.service; then
        log_success "服务运行正常!"
        echo ""
        sudo systemctl status qtks.service --no-pager
    else
        log_error "服务启动失败!"
        echo ""
        log_info "查看详细日志:"
        sudo journalctl -u qtks.service -n 20 --no-pager
        exit 1
    fi
fi

# 显示完成信息
echo ""
log_success "=========================================="
log_success "配置完成!"
log_success "=========================================="
echo ""
log_info "常用命令:"
echo "  启动服务:   sudo systemctl start qtks.service"
echo "  停止服务:   sudo systemctl stop qtks.service"
echo "  重启服务:   sudo systemctl restart qtks.service"
echo "  查看状态:   sudo systemctl status qtks.service"
echo "  查看日志:   sudo journalctl -u qtks.service -f"
echo "  启用自启动: sudo systemctl enable qtks.service"
echo "  禁用自启动: sudo systemctl disable qtks.service"
echo ""
log_info "服务配置文件: /etc/systemd/system/qtks.service"
echo ""
