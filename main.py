#!/usr/bin/env python3
"""
QtKs - 现代化 3D 打印机界面
基于 PySide6 + QML
"""

import sys
import os
import signal
import logging
from pathlib import Path

# 性能优化：禁用 QML 调试日志
# TEMPORARY: Enable for debugging navigation
# os.environ["QT_LOGGING_RULES"] = "*.debug=false;qml=false;js=false"
os.environ["QT_LOGGING_RULES"] = "qt.qml.connections=false;qt.qml.binding=false"
os.environ["QML_CONSOLE_OUTPUT"] = "1"

# 先配置日志 - 生产环境使用 WARNING 级别
logging.basicConfig(
    level=logging.WARNING,  # 从 INFO 改为 WARNING，减少日志输出
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('qtks.log')
    ]
)

logger = logging.getLogger(__name__)

# 设置显示环境 - 支持 WSL Wayland 和 Orange Pi X11
if 'WAYLAND_DISPLAY' in os.environ:
    # WSL 通常使用 Wayland
    os.environ.setdefault('QT_QPA_PLATFORM', 'wayland')
    logger.info("使用 Wayland 显示")
elif 'DISPLAY' in os.environ:
    # X11 环境（如 Orange Pi）
    os.environ.setdefault('QT_QPA_PLATFORM', 'xcb')
    logger.info("使用 X11 显示")
else:
    # 无显示环境，尝试 wayland 或 xcb
    os.environ.setdefault('QT_QPA_PLATFORM', 'wayland')
    logger.warning("未检测到显示环境，尝试 Wayland")

os.environ.setdefault('QT_QUICK_CONTROLS_STYLE', 'Material')

from PySide6.QtGui import QGuiApplication, QIcon, QPixmapCache
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, Qt, qInstallMessageHandler, QtMsgType

from backend.application import Application
from backend.theme_manager import ThemeManager
from backend.icon_loader import IconLoader
from backend.asset_cache import AssetCache
from backend.theme_provider import ThemeProvider


def qt_message_handler(mode, context, message):
    """处理 Qt 消息，包括 QML console.log"""
    if mode == QtMsgType.QtDebugMsg:
        print(f"[QML] {message}")
    elif mode == QtMsgType.QtInfoMsg:
        print(f"[INFO] {message}")
    elif mode == QtMsgType.QtWarningMsg:
        print(f"[WARNING] {message}")
    elif mode == QtMsgType.QtCriticalMsg:
        print(f"[CRITICAL] {message}")
    elif mode == QtMsgType.QtFatalMsg:
        print(f"[FATAL] {message}")


def signal_handler(sig, frame):
    """处理 Ctrl+C"""
    logger.info("接收到退出信号")
    QGuiApplication.quit()


def main():
    """主函数"""
    # 安装消息处理器来捕获 QML console.log
    qInstallMessageHandler(qt_message_handler)

    logger.info("=== QtKs 启动 ===")

    # 设置信号处理
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # 创建应用
    app = QGuiApplication(sys.argv)
    app.setApplicationName("QtKs")
    app.setApplicationVersion("1.0.0")
    app.setOrganizationName("QtKs")

    # 设置样式
    app.setApplicationDisplayName("QtKs - 3D Printer Interface")

    # 创建后端应用
    backend_app = Application()

    # 设置图标缓存大小 (20MB)
    QPixmapCache.setCacheLimit(20 * 1024)  # 20MB in KB
    logger.info("QPixmapCache set to 20MB")

    # 创建主题系统
    try:
        asset_cache = AssetCache(max_cache_size=20 * 1024 * 1024)  # 20MB
        icon_loader = IconLoader(cache=asset_cache)
        theme_manager = ThemeManager(theme_dir="KlipperScreen/styles", cache=asset_cache)
        theme_provider = ThemeProvider(theme_manager, icon_loader)

        # 加载默认主题
        if not theme_provider.initializeTheme("material-dark"):
            logger.warning("Failed to load default theme, continuing with fallback")

        logger.info("✓ Theme system initialized")
    except Exception as e:
        logger.error(f"Failed to initialize theme system: {e}")
        # Create dummy theme provider to prevent crashes
        theme_provider = None

    # 创建 QML 引擎
    engine = QQmlApplicationEngine()

    # 注册后端对象到 QML
    engine.rootContext().setContextProperty("app", backend_app)
    engine.rootContext().setContextProperty("navigationManager", backend_app.navigationManager)

    if theme_provider:
        engine.rootContext().setContextProperty("ThemeProvider", theme_provider)

    # 加载 QML
    qml_file = Path(__file__).parent / "qml" / "MainWindow.qml"

    if not qml_file.exists():
        logger.error(f"QML 文件不存在: {qml_file}")
        return 1

    # 连接错误信号
    def on_warnings(warnings):
        for warning in warnings:
            print(f"QML Warning: {warning.toString()}")

    engine.warnings.connect(on_warnings)

    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        logger.error("无法加载 QML 文件")
        return 1

    print("✓ QML 加载成功")
    print(f"✓ Root objects: {len(engine.rootObjects())}")
    logger.info("✓ QML 加载成功")

    # 初始化后端
    backend_app.initialize()

    # 运行应用
    exit_code = app.exec()

    # 清理
    backend_app.quit()
    logger.info("=== QtKs 退出 ===")

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
