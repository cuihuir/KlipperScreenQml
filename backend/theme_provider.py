# Theme Provider for QML
# QML 主题提供者
"""
ThemeProvider exposes theme data to QML as a QObject.

主题提供者将主题数据作为 QObject 暴露给 QML。
"""

from PySide6.QtCore import QObject, Property, Signal, Slot
from typing import List, Optional
import logging

from .theme_manager import ThemeManager
from .icon_loader import IconLoader
from .models.theme import Theme

logger = logging.getLogger(__name__)


class ThemeProvider(QObject):
    """
    Qt QObject that provides theme data to QML.
    向 QML 提供主题数据的 Qt QObject。
    """

    # Signals / 信号
    themeChanged = Signal()
    themeLoadError = Signal(str)

    def __init__(self, theme_manager: ThemeManager, icon_loader: IconLoader, parent=None):
        """
        Initialize ThemeProvider.

        Args:
            theme_manager (ThemeManager): Theme manager instance
            icon_loader (IconLoader): Icon loader instance
            parent: QObject parent
        """
        super().__init__(parent)
        self._theme_manager = theme_manager
        self._icon_loader = icon_loader
        self._current_theme: Optional[Theme] = None

    # Properties / 属性

    @Property(str, notify=themeChanged)
    def currentTheme(self) -> str:
        """Current theme name / 当前主题名称"""
        if self._current_theme:
            return self._current_theme.name
        return ""

    @Property(str, notify=themeChanged)
    def backgroundColor(self) -> str:
        """Background color / 背景色"""
        if self._current_theme:
            return self._current_theme.colors.bg
        return "#13181C"

    @Property(str, notify=themeChanged)
    def textColor(self) -> str:
        """Text color / 文字色"""
        if self._current_theme:
            return self._current_theme.colors.text
        return "#FFFFFF"

    @Property(str, notify=themeChanged)
    def color1(self) -> str:
        """Primary color 1 / 主题色 1"""
        if self._current_theme:
            return self._current_theme.colors.color1
        return "#ED6500"

    @Property(str, notify=themeChanged)
    def color2(self) -> str:
        """Primary color 2 / 主题色 2"""
        if self._current_theme:
            return self._current_theme.colors.color2
        return "#B10080"

    @Property(str, notify=themeChanged)
    def color3(self) -> str:
        """Primary color 3 / 主题色 3"""
        if self._current_theme:
            return self._current_theme.colors.color3
        return "#009384"

    @Property(str, notify=themeChanged)
    def color4(self) -> str:
        """Primary color 4 / 主题色 4"""
        if self._current_theme:
            return self._current_theme.colors.color4
        return "#A7E100"

    @Property(str, notify=themeChanged)
    def activeColor(self) -> str:
        """Active state color / 激活状态色"""
        if self._current_theme:
            return self._current_theme.colors.active
        return "#ED6500"

    @Property(str, notify=themeChanged)
    def warningColor(self) -> str:
        """Warning color / 警告色"""
        if self._current_theme:
            return self._current_theme.colors.warning
        return "#FFA500"

    @Property(str, notify=themeChanged)
    def errorColor(self) -> str:
        """Error color / 错误色"""
        if self._current_theme:
            return self._current_theme.colors.error
        return "#FF0000"

    # Slots / 槽函数

    @Slot(str, result=str)
    def getIconPath(self, icon_name: str) -> str:
        """
        Get icon path for QML Image source.
        获取用于 QML Image source 的图标路径。

        Args:
            icon_name (str): Icon name (without extension)

        Returns:
            str: file:// URL to icon
        """
        if not self._current_theme:
            logger.warning("No theme loaded, cannot get icon path")
            return ""

        try:
            return self._icon_loader.getIconPath(icon_name, self._current_theme, format="file")
        except Exception as e:
            logger.error(f"Failed to get icon path for {icon_name}: {e}")
            return ""

    @Slot(result='QStringList')
    def getAvailableThemes(self) -> List[str]:
        """
        Get list of available themes.
        获取可用主题列表。

        Returns:
            List[str]: Theme names
        """
        return self._theme_manager.listAvailableThemes()

    @Slot(str)
    def setTheme(self, theme_name: str) -> None:
        """
        Set current theme.
        设置当前主题。

        Args:
            theme_name (str): Theme name to load
        """
        try:
            logger.info(f"Switching to theme: {theme_name}")

            # Load new theme
            new_theme = self._theme_manager.loadTheme(theme_name)

            # Clear icon cache
            if self._icon_loader.cache:
                self._icon_loader.cache.clear()

            # Update current theme
            self._current_theme = new_theme

            # Notify QML
            self.themeChanged.emit()

            logger.info(f"Theme switched successfully: {theme_name}")

        except Exception as e:
            error_msg = f"Failed to load theme {theme_name}: {e}"
            logger.error(error_msg)
            self.themeLoadError.emit(error_msg)

    @Slot(str)
    def loadTheme(self, theme_name: str) -> None:
        """
        Load theme (alias for setTheme).
        加载主题（setTheme 的别名）。

        Args:
            theme_name (str): Theme name
        """
        self.setTheme(theme_name)

    # Public methods / 公共方法

    def getCurrentTheme(self) -> Optional[Theme]:
        """
        Get current theme object.
        获取当前主题对象。

        Returns:
            Optional[Theme]: Current theme or None
        """
        return self._current_theme

    def initializeTheme(self, theme_name: str) -> bool:
        """
        Initialize with default theme.
        使用默认主题初始化。

        Args:
            theme_name (str): Theme name to load

        Returns:
            bool: True if successful
        """
        try:
            self._current_theme = self._theme_manager.loadTheme(theme_name)
            logger.info(f"ThemeProvider initialized with theme: {theme_name}")
            return True
        except Exception as e:
            logger.error(f"Failed to initialize theme: {e}")
            return False
