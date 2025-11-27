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
os.environ["QT_LOGGING_RULES"] = "*.debug=false;qml=false;js=false"

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

from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, Qt

from backend.application import Application


def signal_handler(sig, frame):
    """处理 Ctrl+C"""
    logger.info("接收到退出信号")
    QGuiApplication.quit()


def main():
    """主函数"""
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

    # 创建 QML 引擎
    engine = QQmlApplicationEngine()

    # 注册后端对象到 QML
    engine.rootContext().setContextProperty("app", backend_app)
    engine.rootContext().setContextProperty("navigationManager", backend_app.navigationManager)

    # 加载 QML
    qml_file = Path(__file__).parent / "qml" / "MainWindow.qml"

    if not qml_file.exists():
        logger.error(f"QML 文件不存在: {qml_file}")
        return 1

    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        logger.error("无法加载 QML 文件")
        return 1

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
