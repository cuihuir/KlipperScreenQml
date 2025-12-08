# SVG Processor for QtKs
# SVG 处理器 - 处理有问题的 SVG 文件
"""
SVGProcessor handles preprocessing of problematic SVG files.

SVG 处理器处理有问题的 SVG 文件的预处理。
"""

import re
from pathlib import Path
import logging

logger = logging.getLogger(__name__)


def preprocess_spool_svg(svg_path: Path, filament_color: str = "#ED6500") -> str:
    """
    Preprocess spool.svg with CSS variable substitution.
    预处理 spool.svg，替换 CSS 变量。

    Args:
        svg_path (Path): Path to spool.svg
        filament_color (str): Color to use for filament (hex format)

    Returns:
        str: Processed SVG content
    """
    if not svg_path.exists():
        raise FileNotFoundError(f"SVG file not found: {svg_path}")

    with open(svg_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace CSS variable references with actual color
    # var(--filament-color) → actual color value
    processed = re.sub(
        r'var\(--filament-color\)',
        filament_color,
        content
    )

    logger.debug(f"Preprocessed spool.svg with color: {filament_color}")
    return processed


def is_problematic_svg(icon_name: str) -> bool:
    """
    Check if icon is known to have compatibility issues.
    检查图标是否已知有兼容性问题。

    Args:
        icon_name (str): Icon name (without extension)

    Returns:
        bool: True if icon needs preprocessing
    """
    # Known problematic icons
    problematic = {
        'spool',      # Uses CSS variables
        'spoolman',   # Uses clipPath (may need conversion)
    }

    return icon_name in problematic


def get_preprocessed_svg(icon_path: Path, icon_name: str, **kwargs) -> str:
    """
    Get preprocessed SVG content for problematic icons.
    获取有问题图标的预处理 SVG 内容。

    Args:
        icon_path (Path): Path to SVG file
        icon_name (str): Icon name
        **kwargs: Additional parameters (e.g., filament_color for spool.svg)

    Returns:
        str: Preprocessed SVG content

    Raises:
        NotImplementedError: If preprocessing not implemented for this icon
    """
    if icon_name == 'spool':
        filament_color = kwargs.get('filament_color', '#ED6500')
        return preprocess_spool_svg(icon_path, filament_color)

    elif icon_name == 'spoolman':
        # For spoolman, just return as-is for now
        # Qt SVG renderer can handle most clipPath cases
        # If issues arise, can use Inkscape conversion:
        # inkscape --export-plain-svg=output.svg input.svg
        logger.debug(f"Loading spoolman.svg without preprocessing (Qt handles clipPath)")
        with open(icon_path, 'r', encoding='utf-8') as f:
            return f.read()

    else:
        raise NotImplementedError(f"No preprocessing defined for icon: {icon_name}")
