#!/usr/bin/env python3
"""
主应用程序类模块

此模块定义了QtKs应用程序的核心类，负责：
1. 管理配置系统
2. 管理Moonraker客户端连接
3. 向QML暴露Python对象和属性
4. 处理应用程序生命周期事件
"""

import logging
from PySide6.QtCore import QObject, Signal, Slot, Property
from backend.moonraker_client import MoonrakerClient
from backend.config_manager import ConfigManager
from backend.ui_state import UIState
from backend.navigation_manager import NavigationManager


class Application(QObject):
    """
    主应用程序类

    作为QtKs应用程序的核心控制器，负责管理所有后端组件
    并向QML层暴露必要的接口。

    Signals:
        initialized: 应用初始化完成信号
        themeChanged: 主题切换信号

    Attributes:
        config: 配置管理器实例
        moonraker: Moonraker客户端实例
        logger: 日志记录器

    Example:
        >>> app = Application()
        >>> app.initialize()
        >>> host = app.printerHost
    """

    # 信号
    initialized = Signal()
    themeChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self.logger = logging.getLogger(__name__)

        # 加载配置
        self.config = ConfigManager()

        # 创建 Moonraker 客户端
        self._printer_host = self.config.get("printer.host", "192.168.200.209")
        self._printer_port = self.config.get("printer.port", 7125)
        self.moonraker = MoonrakerClient(host=self._printer_host, port=self._printer_port, parent=self)

        # 创建 UI 状态管理器
        self.ui_state = UIState(parent=self)

        # 创建导航管理器
        self.navigation_manager = NavigationManager(parent=self)

        # 应用状态
        self._theme = "dark"
        self._app_name = "QtKs - Modern 3D Printer Interface"
        self._version = "1.0.0"

        # UI 配置 - 使用 1920x440 超宽屏
        self._ui_width = self.config.get("ui.width", 1920)
        self._ui_height = self.config.get("ui.height", 440)

        # 连接信号
        self._connect_signals()

        self.logger.info("应用程序初始化完成")

    def _connect_signals(self):
        """连接信号"""
        self.moonraker.printerConnected.connect(self._on_printer_connected)
        self.moonraker.printerDisconnected.connect(self._on_printer_disconnected)
        self.moonraker.connectionError.connect(self._on_connection_error)

    # === 属性 ===
    @Property(str, notify=themeChanged)
    def theme(self):
        return self._theme

    @Property(str, constant=True)
    def appName(self):
        return self._app_name

    @Property(str, constant=True)
    def version(self):
        return self._version

    @Property(QObject, constant=True)
    def printer(self):
        """返回打印机客户端对象给QML使用"""
        return self.moonraker

    @Property(QObject, constant=True)
    def uiState(self):
        """返回UI状态管理器对象给QML使用"""
        return self.ui_state

    @Property(QObject, constant=True)
    def navigationManager(self):
        """返回导航管理器对象给QML使用"""
        return self.navigation_manager

    @Property(QObject, constant=True)
    def settings(self):
        """返回配置管理器对象给QML使用"""
        return self.config

    @Property(int, constant=True)
    def uiWidth(self):
        """UI 宽度"""
        return self._ui_width

    @Property(int, constant=True)
    def uiHeight(self):
        """UI 高度"""
        return self._ui_height

    @Property(str, constant=True)
    def printerHost(self):
        """打印机主机地址"""
        return self._printer_host

    @Property(int, constant=True)
    def printerPort(self):
        """打印机端口"""
        return self._printer_port

    # === 槽函数 ===
    @Slot()
    def initialize(self):
        """
        初始化应用程序

        测试打印机连接并启动WebSocket监听。
        初始化完成后发出initialized信号。
        """
        self.logger.info("初始化应用...")

        # 启动UI状态管理
        self.ui_state.start_idle_detection()
        self.logger.info("UI状态管理器已启动")

        # 测试连接
        if self.moonraker.testConnection():
            self.logger.info("打印机连接正常")
            # 启动 WebSocket 连接
            self.moonraker.connectPrinter()
        else:
            self.logger.warning("无法连接到打印机，将稍后重试")
            # 仍然尝试连接 WebSocket
            self.moonraker.connectPrinter()

        self.initialized.emit()

    @Slot(str)
    def setTheme(self, theme: str):
        """设置主题"""
        if theme != self._theme:
            self._theme = theme
            self.themeChanged.emit()
            self.logger.info(f"主题已切换到: {theme}")

    @Slot(str, int)
    def saveConnectionAndReconnect(self, host: str, port: int):
        """
        保存打印机连接配置并重新连接

        Args:
            host: 打印机IP地址
            port: 打印机端口号

        此方法会：
        1. 保存新配置到config.json
        2. 断开现有连接
        3. 创建新的Moonraker客户端
        4. 尝试连接到新地址
        """
        self.logger.info(f"保存连接配置: {host}:{port}")

        # 保存到配置
        self.config.set("printer.host", host)
        self.config.set("printer.port", port)
        self.config.save()

        # 断开当前连接
        self.moonraker.disconnectPrinter()

        # 创建新的客户端
        self.moonraker = MoonrakerClient(host=host, port=port, parent=self)
        self._connect_signals()

        # 重新连接
        if self.moonraker.testConnection():
            self.logger.info("重新连接成功")
            self.moonraker.connectPrinter()
        else:
            self.logger.warning("重新连接失败，将稍后重试")
            self.moonraker.connectPrinter()

    @Slot()
    def quit(self):
        """
        退出应用程序

        断开所有连接并清理资源。
        """
        self.logger.info("退出应用...")
        self.moonraker.disconnectPrinter()

    # === 私有槽 ===
    def _on_printer_connected(self):
        """打印机连接成功"""
        self.logger.info("✓ 打印机已连接")

    def _on_printer_disconnected(self):
        """打印机断开连接"""
        self.logger.warning("✗ 打印机已断开")

    def _on_connection_error(self, error: str):
        """连接错误"""
        self.logger.error(f"连接错误: {error}")
