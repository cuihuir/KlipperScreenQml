# GTK CSS Parser for QtKs
# GTK CSS 解析器 - 解析 KlipperScreen CSS 颜色定义
"""
GTKCSSColorResolver parses GTK CSS @define-color definitions and converts
them to QML-compatible format.

GTK CSS 颜色解析器解析 GTK CSS @define-color 定义并转换为 QML 兼容格式。
"""

import re
from pathlib import Path
from typing import Dict
import logging

logger = logging.getLogger(__name__)


class ParseError(Exception):
    """CSS 解析失败 / CSS parsing failed"""
    pass


class GTKCSSColorResolver:
    """
    Parses GTK CSS color definitions and converts to QML format.
    解析 GTK CSS 颜色定义并转换为 QML 格式。
    """

    # Regex pattern for @define-color
    COLOR_PATTERN = re.compile(r'@define-color\s+(\w+)\s+([^;]+);')

    def __init__(self):
        """Initialize CSS parser."""
        pass

    def parse_file(self, css_path: str) -> Dict[str, str]:
        """
        Parse CSS file and return color dictionary.
        解析 CSS 文件返回颜色字典。

        Args:
            css_path (str): Path to CSS file

        Returns:
            Dict[str, str]: Color name to value mapping

        Raises:
            FileNotFoundError: CSS file not found
            ParseError: CSS parsing failed
        """
        css_file = Path(css_path)
        if not css_file.exists():
            raise FileNotFoundError(f"CSS file not found: {css_path}")

        logger.info(f"Parsing CSS file: {css_path}")

        with open(css_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extract @define-color definitions
        colors = {}
        for match in self.COLOR_PATTERN.finditer(content):
            color_name = match.group(1)
            color_value = match.group(2).strip()
            colors[color_name] = color_value

        logger.debug(f"Found {len(colors)} color definitions")

        # Resolve color references (@bg, @text, etc.)
        resolved = self._resolve_references(colors)

        return resolved

    def _resolve_references(self, colors: Dict[str, str]) -> Dict[str, str]:
        """
        Recursively resolve color variable references.
        递归解析颜色变量引用。

        Args:
            colors (Dict[str, str]): Raw color definitions

        Returns:
            Dict[str, str]: Resolved color values
        """
        resolved = {}

        for name, value in colors.items():
            resolved[name] = self._resolve_value(value, colors, set())

        return resolved

    def _resolve_value(self, value: str, colors: Dict[str, str], visited: set) -> str:
        """
        Resolve a single color value, handling references.
        解析单个颜色值，处理引用。

        Args:
            value (str): Color value (may contain @references)
            colors (Dict[str, str]): All color definitions
            visited (set): Track visited references to prevent cycles

        Returns:
            str: Resolved color value
        """
        # If value starts with @, it's a reference
        if value.startswith('@'):
            ref_name = value[1:]  # Remove @ prefix

            # Prevent infinite recursion
            if ref_name in visited:
                logger.warning(f"Circular reference detected: {ref_name}")
                return value

            # Resolve the reference
            if ref_name in colors:
                visited.add(ref_name)
                return self._resolve_value(colors[ref_name], colors, visited)
            else:
                logger.warning(f"Undefined color reference: {ref_name}")
                return value

        # Already a concrete value (hex color)
        return value

    def to_qml_format(self, colors: Dict[str, str]) -> str:
        """
        Convert to QML Singleton format.
        转换为 QML Singleton 格式。

        Args:
            colors (Dict[str, str]): Resolved color dictionary

        Returns:
            str: QML file content
        """
        qml_lines = [
            "// Auto-generated from KlipperScreen CSS",
            "// 从 KlipperScreen CSS 自动生成",
            "pragma Singleton",
            "import QtQuick",
            "",
            "QtObject {",
        ]

        # Add color properties
        for name, value in sorted(colors.items()):
            # Convert snake_case to camelCase for QML
            qml_name = self._to_camel_case(name)
            qml_color = self._css_to_qml_color(value)
            qml_lines.append(f'    readonly property color {qml_name}: "{qml_color}"')

        qml_lines.append("}")

        return "\n".join(qml_lines)

    def _to_camel_case(self, name: str) -> str:
        """
        Convert snake_case to camelCase.
        转换命名为驼峰格式。

        Args:
            name (str): Snake case name (e.g., "text_inv")

        Returns:
            str: Camel case name (e.g., "textInv")
        """
        parts = name.split('_')
        if len(parts) == 1:
            return name

        # First part lowercase, rest capitalized
        return parts[0] + ''.join(p.capitalize() for p in parts[1:])

    def _css_to_qml_color(self, css_color: str) -> str:
        """
        Convert CSS color to QML hex format.
        CSS 颜色转 QML 十六进制格式。

        Args:
            css_color (str): CSS color value

        Returns:
            str: QML color format (#RRGGBB)
        """
        # Remove whitespace
        color = css_color.strip().lower()

        # If already in hex format, return as-is
        if color.startswith('#'):
            return color.upper()

        # Handle named colors
        named_colors = {
            'white': '#FFFFFF',
            'black': '#000000',
            'red': '#FF0000',
            'green': '#00FF00',
            'blue': '#0000FF',
            'yellow': '#FFFF00',
            'cyan': '#00FFFF',
            'magenta': '#FF00FF',
            'gray': '#808080',
            'grey': '#808080',
        }

        if color in named_colors:
            return named_colors[color]

        # Unknown color format, return as-is and warn
        logger.warning(f"Unsupported color format: {css_color}")
        return css_color
