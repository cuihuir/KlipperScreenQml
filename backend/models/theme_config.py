# Theme Configuration Data Model
# 主题配置数据模型
"""
ThemeConfiguration represents user theme settings from config.json.

主题配置表示来自 config.json 的用户主题设置。
"""

from dataclasses import dataclass
from pathlib import Path
from typing import Optional


@dataclass
class ThemeConfiguration:
    """
    User theme configuration settings.
    用户主题配置设置。
    """

    # Theme selection / 主题选择
    selected_theme: str = "material-dark"        # Currently selected theme name

    # Theme directories / 主题目录
    theme_dir: str = "KlipperScreen/styles"      # Base theme directory
    fallback_theme: str = "base"                 # Fallback theme name

    # Custom icons / 自定义图标
    custom_icons_enabled: bool = False           # Enable custom icons
    custom_icons_dir: str = ""                   # Custom icons directory path

    def __post_init__(self):
        """Validate configuration after initialization."""
        self._validate()

    def _validate(self):
        """
        Validate theme configuration.
        验证主题配置。

        Raises:
            ValueError: If validation fails
        """
        if not self.selected_theme:
            raise ValueError("selected_theme cannot be empty")

        if not self.theme_dir:
            raise ValueError("theme_dir cannot be empty")

        if not self.fallback_theme:
            raise ValueError("fallback_theme cannot be empty")

    @property
    def theme_dir_path(self) -> Path:
        """
        Get theme directory as Path object.
        获取主题目录作为 Path 对象。

        Returns:
            Path: Theme directory path
        """
        return Path(self.theme_dir)

    @property
    def custom_icons_dir_path(self) -> Optional[Path]:
        """
        Get custom icons directory as Path object.
        获取自定义图标目录作为 Path 对象。

        Returns:
            Optional[Path]: Custom icons directory path or None
        """
        if self.custom_icons_enabled and self.custom_icons_dir:
            return Path(self.custom_icons_dir)
        return None

    def get_theme_path(self, theme_name: str) -> Path:
        """
        Get full path to a specific theme directory.
        获取特定主题目录的完整路径。

        Args:
            theme_name (str): Theme name

        Returns:
            Path: Full path to theme directory
        """
        return self.theme_dir_path / theme_name

    @classmethod
    def from_dict(cls, config: dict) -> 'ThemeConfiguration':
        """
        Create ThemeConfiguration from config dictionary.
        从配置字典创建主题配置。

        Args:
            config (dict): Configuration dictionary

        Returns:
            ThemeConfiguration: New configuration instance
        """
        # Extract only relevant fields
        theme_config = config.get('theme', {})

        return cls(
            selected_theme=theme_config.get('selected_theme', 'material-dark'),
            theme_dir=theme_config.get('theme_dir', 'KlipperScreen/styles'),
            fallback_theme=theme_config.get('fallback_theme', 'base'),
            custom_icons_enabled=theme_config.get('custom_icons_enabled', False),
            custom_icons_dir=theme_config.get('custom_icons_dir', '')
        )

    def __repr__(self) -> str:
        """String representation for debugging."""
        return (
            f"ThemeConfiguration(selected='{self.selected_theme}', "
            f"dir='{self.theme_dir}', custom_icons={self.custom_icons_enabled})"
        )
