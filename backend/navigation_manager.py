#!/usr/bin/env python3
"""
导航管理器模块

此模块管理页面导航栈和历史记录，支持 iOS 风格的层级导航。
"""

import logging
from PySide6.QtCore import QObject, Signal, Slot, Property


class NavigationManager(QObject):
    """
    导航管理器 - 管理页面栈和历史

    负责维护导航历史栈，支持 push/pop 操作，并发射导航相关信号。

    Signals:
        navigationChanged: 导航状态变化 (page_id: str, depth: int)
        depthChanged: 导航深度变化 (depth: int)
        currentPageChanged: 当前页面变化 (page_id: str)
        canGoBackChanged: 返回按钮可用状态变化 (can_go_back: bool)
        pageEntered: 页面进入 (page_id: str)
        pageExited: 页面退出 (page_id: str)

    Attributes:
        _navigation_stack: 导航历史栈（页面 ID 列表）
        _current_page: 当前页面 ID
        _can_go_back: 是否可以返回上一级

    Example:
        >>> nav = NavigationManager()
        >>> nav.pushPage("settings")
        >>> print(nav.currentDepth)  # 2
        >>> nav.popPage()
    """

    # 信号定义
    navigationChanged = Signal(str, int)  # (page_id, depth)
    depthChanged = Signal(int)            # depth
    currentPageChanged = Signal(str)      # page_id
    canGoBackChanged = Signal(bool)       # can_go_back
    pageEntered = Signal(str)             # page_id
    pageExited = Signal(str)              # page_id

    def __init__(self, parent=None):
        super().__init__(parent)

        self.logger = logging.getLogger(__name__)

        # 初始化导航栈（主页为根）
        self._navigation_stack = ["home"]
        self._current_page = "home"
        self._can_go_back = False

        self.logger.info("NavigationManager 初始化完成")

    # ===== 只读属性（QML 绑定） =====

    @Property(int, notify=depthChanged)
    def currentDepth(self):
        """当前导航栈深度"""
        return len(self._navigation_stack)

    @Property(str, notify=currentPageChanged)
    def currentPage(self):
        """当前页面 ID"""
        return self._current_page

    @Property(bool, notify=canGoBackChanged)
    def canGoBack(self):
        """是否可以返回上一级"""
        return self._can_go_back

    # ===== QML 调用的方法 =====

    @Slot(str)
    def pushPage(self, page_id: str):
        """
        推送新页面到导航栈

        Args:
            page_id: 页面标识符（如 "settings", "control", "files"）
        """
        if not page_id:
            self.logger.warning("pushPage 调用时 page_id 为空")
            return

        # 记录退出旧页面
        old_page = self._current_page
        self.pageExited.emit(old_page)

        # 推送新页面
        self._navigation_stack.append(page_id)
        self._current_page = page_id
        self._can_go_back = len(self._navigation_stack) > 1

        self.logger.info(f"推送页面: {page_id}，当前深度: {len(self._navigation_stack)}")

        # 发射信号通知 QML 更新
        self.pageEntered.emit(page_id)
        self.navigationChanged.emit(page_id, len(self._navigation_stack))
        self.currentPageChanged.emit(page_id)
        self.depthChanged.emit(len(self._navigation_stack))
        self.canGoBackChanged.emit(self._can_go_back)

    @Slot()
    def popPage(self):
        """
        弹出当前页面，返回上一级

        如果当前在主页（深度=1），则不执行任何操作。
        """
        if len(self._navigation_stack) <= 1:
            self.logger.warning("已在主页，无法继续返回")
            return  # 不能弹出主页

        # 记录退出当前页面
        old_page = self._current_page
        self.pageExited.emit(old_page)

        # 弹出当前页面
        self._navigation_stack.pop()
        self._current_page = self._navigation_stack[-1]
        self._can_go_back = len(self._navigation_stack) > 1

        self.logger.info(f"弹出页面: {old_page}，返回: {self._current_page}，深度: {len(self._navigation_stack)}")

        # 发射信号
        self.pageEntered.emit(self._current_page)
        self.navigationChanged.emit(self._current_page, len(self._navigation_stack))
        self.currentPageChanged.emit(self._current_page)
        self.depthChanged.emit(len(self._navigation_stack))
        self.canGoBackChanged.emit(self._can_go_back)

    @Slot()
    def popToRoot(self):
        """
        弹出所有页面，返回主页

        如果已经在主页，则不执行任何操作。
        """
        if len(self._navigation_stack) == 1:
            self.logger.info("已在主页")
            return  # 已经在主页

        # 记录退出当前页面
        old_page = self._current_page
        self.pageExited.emit(old_page)

        # 清空栈，仅保留主页
        self._navigation_stack = ["home"]
        self._current_page = "home"
        self._can_go_back = False

        self.logger.info(f"返回主页（从 {old_page}）")

        # 发射信号
        self.pageEntered.emit("home")
        self.navigationChanged.emit("home", 1)
        self.currentPageChanged.emit("home")
        self.depthChanged.emit(1)
        self.canGoBackChanged.emit(False)

    @Slot(int)
    def popToDepth(self, depth: int):
        """
        弹出到指定深度

        Args:
            depth: 目标深度（必须 >= 1 且 <= 当前深度）
        """
        if depth < 1:
            self.logger.error(f"无效的目标深度: {depth}（必须 >= 1）")
            return

        current_depth = len(self._navigation_stack)
        if depth >= current_depth:
            self.logger.warning(f"目标深度 {depth} 大于等于当前深度 {current_depth}")
            return

        # 记录退出当前页面
        old_page = self._current_page
        self.pageExited.emit(old_page)

        # 截取栈到指定深度
        self._navigation_stack = self._navigation_stack[:depth]
        self._current_page = self._navigation_stack[-1]
        self._can_go_back = len(self._navigation_stack) > 1

        self.logger.info(f"弹出到深度 {depth}，当前页面: {self._current_page}")

        # 发射信号
        self.pageEntered.emit(self._current_page)
        self.navigationChanged.emit(self._current_page, depth)
        self.currentPageChanged.emit(self._current_page)
        self.depthChanged.emit(depth)
        self.canGoBackChanged.emit(self._can_go_back)

    # ===== 调试辅助方法 =====

    @Slot()
    def debugPrintStack(self):
        """打印当前导航栈（调试用）"""
        self.logger.debug(f"导航栈: {self._navigation_stack}")
        self.logger.debug(f"当前页面: {self._current_page}")
        self.logger.debug(f"深度: {len(self._navigation_stack)}")
        self.logger.debug(f"可返回: {self._can_go_back}")
