# Color Palette Data Model
# 颜色调色板数据模型
"""
ColorPalette represents a theme's color scheme from KlipperScreen CSS.

颜色调色板表示来自 KlipperScreen CSS 的主题配色方案。
"""

from dataclasses import dataclass, field
import re
from typing import Dict


@dataclass
class ColorPalette:
    """
    Theme color palette with validation.
    主题颜色调色板（带验证）。

    All colors must be in hex format: #RRGGBB or #RRGGBBAA
    所有颜色必须为十六进制格式：#RRGGBB 或 #RRGGBBAA
    """

    # Primary colors / 主色调
    color1: str = "#ED6500"  # Primary 1
    color2: str = "#B10080"  # Primary 2
    color3: str = "#009384"  # Primary 3
    color4: str = "#A7E100"  # Primary 4

    # Background and text / 背景和文字
    bg: str = "#13181C"           # Background
    text: str = "#F0F0F0"         # Text color
    textInv: str = "#202020"      # Inverted text

    # State colors / 状态颜色
    active: str = "#ED6500"       # Active state
    warning: str = "#FFA500"      # Warning
    error: str = "#FF0000"        # Error
    success: str = "#00FF00"      # Success (optional)

    # UI elements / UI 元素
    lines: str = "#404040"        # Lines and borders
    panel: str = "#1A1F24"        # Panel background (optional)

    # Additional colors / 额外颜色 (from KlipperScreen CSS)
    color5: str = "#6C7980"       # Secondary color
    color6: str = "#80E400"       # Accent color
    color7: str = "#CE00ED"       # Accent color
    color8: str = "#0086ED"       # Accent color

    # Color validation pattern
    _COLOR_PATTERN = re.compile(r'^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$')

    def __post_init__(self):
        """Validate all color values after initialization."""
        self._validate_colors()

    def _validate_colors(self):
        """
        Validate that all colors are in valid hex format.
        验证所有颜色都是有效的十六进制格式。

        Raises:
            ValueError: If any color is invalid
        """
        for field_name, value in self.__dict__.items():
            # Skip private fields and validation pattern
            if field_name.startswith('_'):
                continue

            if not self._COLOR_PATTERN.match(value):
                raise ValueError(
                    f"Invalid color format for {field_name}: {value}. "
                    f"Expected #RRGGBB or #RRGGBBAA format."
                )

    def to_dict(self) -> Dict[str, str]:
        """
        Convert palette to dictionary.
        转换调色板为字典。

        Returns:
            Dict[str, str]: Color name to hex value mapping
        """
        return {
            field_name: value
            for field_name, value in self.__dict__.items()
            if not field_name.startswith('_')
        }

    @classmethod
    def from_dict(cls, colors: Dict[str, str]) -> 'ColorPalette':
        """
        Create ColorPalette from dictionary.
        从字典创建颜色调色板。

        Args:
            colors (Dict[str, str]): Color name to value mapping

        Returns:
            ColorPalette: New palette instance
        """
        # Filter to only valid fields
        valid_fields = {
            k: v for k, v in colors.items()
            if not k.startswith('_') and hasattr(cls, k)
        }

        return cls(**valid_fields)

    def __repr__(self) -> str:
        """String representation for debugging."""
        return (
            f"ColorPalette(color1={self.color1}, color2={self.color2}, "
            f"bg={self.bg}, text={self.text}, active={self.active})"
        )
