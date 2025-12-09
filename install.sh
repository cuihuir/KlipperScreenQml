#!/bin/bash

###############################################################################
# QtKs 自动化安装脚本
# 适用于 Orange Pi / Raspberry Pi / 其他 Debian/Ubuntu 系统
#
# ⚠️  状态：未验证
# 本脚本尚未在实际环境中完整验证，使用前请谨慎
# 验证完成后请更新 CLAUDE.md 文档
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测系统信息
detect_system() {
    log_info "检测系统信息..."

    OS=$(uname -s)
    ARCH=$(uname -m)

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
    fi

    log_info "操作系统: $OS_NAME $OS_VERSION"
    log_info "架构: $ARCH"

    # 检测包管理器
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
    else
        log_error "不支持的包管理器，目前仅支持 apt-get 和 yum"
        exit 1
    fi

    log_success "系统检测完成"
}

# 检查 root 权限
check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "不建议以 root 用户运行此脚本"
        read -p "是否继续? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 安装系统依赖
install_system_dependencies() {
    log_info "安装系统依赖..."

    if [ "$PKG_MANAGER" = "apt-get" ]; then
        log_info "更新软件包列表..."
        sudo apt-get update

        log_info "安装 Python 和 Qt 基础依赖..."
        sudo apt-get install -y \
            python3 \
            python3-pip \
            python3-venv \
            qt6-base-dev

        log_info "安装 Qt XCB 平台插件依赖..."
        sudo apt-get install -y \
            libxcb-cursor0 \
            libxcb-xinerama0 \
            libxcb-icccm4 \
            libxcb-image0 \
            libxcb-keysyms1 \
            libxcb-randr0 \
            libxcb-render-util0 \
            libxcb-shape0 \
            libxcb-xfixes0

        log_info "安装其他工具..."
        sudo apt-get install -y git curl

    elif [ "$PKG_MANAGER" = "yum" ]; then
        log_info "更新软件包列表..."
        sudo yum update -y

        log_info "安装依赖..."
        sudo yum install -y \
            python3 \
            python3-pip \
            python3-virtualenv \
            qt6-qtbase-devel \
            xcb-util-cursor \
            git \
            curl
    fi

    log_success "系统依赖安装完成"
}

# 设置 Python 虚拟环境
setup_python_env() {
    log_info "设置 Python 虚拟环境..."

    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd "$SCRIPT_DIR"

    if [ -d "venv" ]; then
        log_warning "虚拟环境已存在，是否删除重建? (y/N)"
        read -p "" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf venv
        else
            log_info "跳过虚拟环境创建"
            return
        fi
    fi

    log_info "创建虚拟环境..."
    python3 -m venv venv

    log_info "激活虚拟环境并安装依赖..."
    source venv/bin/activate

    pip install --upgrade pip
    pip install -r requirements.txt

    deactivate

    log_success "Python 虚拟环境设置完成"
}

# 配置文件设置
setup_config() {
    log_info "配置应用..."

    if [ ! -f "config.json" ]; then
        if [ -f "config.example.json" ]; then
            cp config.example.json config.json
            log_success "已创建 config.json，请手动编辑打印机 IP 地址"
            log_warning "编辑文件: nano config.json"
        else
            log_error "找不到 config.example.json"
            exit 1
        fi
    else
        log_info "config.json 已存在，跳过"
    fi
}

# 创建 systemd 服务
setup_systemd_service() {
    log_info "配置 systemd 服务..."

    CURRENT_USER=$(whoami)
    INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    PYTHON_PATH="$INSTALL_DIR/venv/bin/python"
    MAIN_PY_PATH="$INSTALL_DIR/main.py"

    # 询问用户选择平台
    log_info "选择 Qt 平台插件:"
    echo "1) xcb (X11, 推荐)"
    echo "2) wayland"
    echo "3) eglfs (直接渲染到 framebuffer)"
    read -p "请选择 [1-3] (默认: 1): " platform_choice

    case ${platform_choice:-1} in
        1) QT_PLATFORM="xcb" ;;
        2) QT_PLATFORM="wayland" ;;
        3) QT_PLATFORM="eglfs" ;;
        *) QT_PLATFORM="xcb" ;;
    esac

    log_info "使用平台: $QT_PLATFORM"

    # 生成 systemd 服务文件
    SERVICE_FILE="/tmp/qtks.service"

    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=QtKs 3D Printer Interface
After=network.target graphical.target
Wants=graphical.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$INSTALL_DIR
Environment="DISPLAY=:0"
Environment="QT_QPA_PLATFORM=$QT_PLATFORM"
Environment="PATH=$INSTALL_DIR/venv/bin:/usr/local/bin:/usr/bin:/bin"

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

    log_info "服务文件已生成，正在安装..."
    sudo mv "$SERVICE_FILE" /etc/systemd/system/qtks.service
    sudo chmod 644 /etc/systemd/system/qtks.service

    log_info "重新加载 systemd 配置..."
    sudo systemctl daemon-reload

    log_success "systemd 服务配置完成"

    # 询问是否启用自启动
    read -p "是否启用开机自启动? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        sudo systemctl enable qtks.service
        log_success "已启用开机自启动"
    fi

    # 询问是否立即启动
    read -p "是否立即启动服务? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        sudo systemctl start qtks.service
        log_success "服务已启动"

        sleep 2
        log_info "服务状态:"
        sudo systemctl status qtks.service --no-pager
    fi
}

# 测试运行
test_run() {
    log_info "是否进行测试运行? (y/N)"
    read -p "" -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "启动测试运行 (按 Ctrl+C 退出)..."
        source venv/bin/activate
        export QT_QPA_PLATFORM=xcb
        python main.py
        deactivate
    fi
}

# 显示完成信息
show_completion_info() {
    echo ""
    log_success "=========================================="
    log_success "QtKs 安装完成!"
    log_success "=========================================="
    echo ""
    log_info "常用命令:"
    echo "  启动服务:   sudo systemctl start qtks.service"
    echo "  停止服务:   sudo systemctl stop qtks.service"
    echo "  重启服务:   sudo systemctl restart qtks.service"
    echo "  查看状态:   sudo systemctl status qtks.service"
    echo "  查看日志:   sudo journalctl -u qtks.service -f"
    echo "  禁用自启动: sudo systemctl disable qtks.service"
    echo ""
    log_info "手动运行:"
    echo "  cd $(pwd)"
    echo "  source venv/bin/activate"
    echo "  python main.py"
    echo ""
    log_warning "记得编辑 config.json 配置打印机 IP 地址!"
    echo "  nano $(pwd)/config.json"
    echo ""
}

# 主函数
main() {
    echo ""
    echo "=========================================="
    echo "    QtKs 自动化安装脚本"
    echo "=========================================="
    echo ""

    check_root
    detect_system
    install_system_dependencies
    setup_python_env
    setup_config
    setup_systemd_service
    show_completion_info
}

# 运行主函数
main
