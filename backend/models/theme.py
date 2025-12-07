# Theme Data Model
# 主题数据模型
"""
Theme represents a complete KlipperScreen theme with colors and icons.

主题表示一个完整的 KlipperScreen 主题，包含颜色和图标。
"""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, Optional
from .color_palette import ColorPalette
from .icon_asset import IconAsset


@dataclass
class Theme:
    """
    Represents a complete KlipperScreen theme.
    表示一个完整的 KlipperScreen 主题。
    """

    # Theme identification / 主题标识
    name: str                                    # Theme name (e.g., "material-dark")
    base_dir: Path                               # Theme directory path

    # Theme assets / 主题素材
    colors: ColorPalette = field(default_factory=ColorPalette)
    icons_dir: Optional[Path] = None             # Icons directory path
    icons: Dict[str, IconAsset] = field(default_factory=dict)  # Loaded icons

    # Theme metadata / 主题元数据
    css_file: Optional[Path] = None              # Theme CSS file path
    base_css_file: Optional[Path] = None         # Base CSS file path

    def __post_init__(self):
        """Validate theme after initialization."""
        self._validate()

    def _validate(self):
        """
        Validate theme data.
        验证主题数据。

        Raises:
            ValueError: If validation fails
        """
        if not self.name:
            raise ValueError("Theme name cannot be empty")

        if not isinstance(self.base_dir, Path):
            raise ValueError(f"base_dir must be a Path object, got {type(self.base_dir)}")

        # Set icons_dir if not provided
        if self.icons_dir is None and self.base_dir.exists():
            potential_icons_dir = self.base_dir / "images"
            if potential_icons_dir.exists():
                self.icons_dir = potential_icons_dir

    @property
    def exists(self) -> bool:
        """
        Check if theme directory exists.
        检查主题目录是否存在。

        Returns:
            bool: True if theme directory exists
        """
        return self.base_dir.exists()

    @property
    def icon_count(self) -> int:
        """
        Get number of loaded icons.
        获取已加载图标数量。

        Returns:
            int: Number of icons
        """
        return len(self.icons)

    def get_icon(self, icon_name: str) -> Optional[IconAsset]:
        """
        Get icon by name.
        按名称获取图标。

        Args:
            icon_name (str): Icon name (without extension)

        Returns:
            Optional[IconAsset]: Icon asset or None if not found
        """
        return self.icons.get(icon_name)

    def add_icon(self, icon: IconAsset) -> None:
        """
        Add icon to theme.
        向主题添加图标。

        Args:
            icon (IconAsset): Icon to add
        """
        self.icons[icon.name] = icon

    def has_icon(self, icon_name: str) -> bool:
        """
        Check if theme has icon.
        检查主题是否有图标。

        Args:
            icon_name (str): Icon name

        Returns:
            bool: True if icon exists in theme
        """
        return icon_name in self.icons

    def __repr__(self) -> str:
        """String representation for debugging."""
        return (
            f"Theme(name='{self.name}', icons={self.icon_count}, "
            f"exists={self.exists})"
        )
