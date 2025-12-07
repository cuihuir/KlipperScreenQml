# Theme Manager for QtKs
# 主题管理器 - 加载和管理 KlipperScreen 主题
"""
ThemeManager handles loading KlipperScreen themes, parsing CSS colors,
and managing theme switching.

主题管理器处理 KlipperScreen 主题的加载、CSS 颜色解析和主题切换。
"""

from pathlib import Path
from typing import Optional, List, Dict
import logging

logger = logging.getLogger(__name__)


class ThemeNotFoundError(Exception):
    """主题目录不存在 / Theme directory not found"""
    pass


class ThemeLoadError(Exception):
    """主题加载失败 / Theme loading failed"""
    pass


class ThemeManager:
    """
    Manages KlipperScreen theme loading and switching.
    管理 KlipperScreen 主题加载和切换。
    """

    # Valid theme names / 有效的主题名称
    VALID_THEMES = [
        "material-dark",
        "material-darker",
        "material-light",
        "colorized",
        "z-bolt",
        "base"
    ]

    def __init__(self, theme_dir: str, cache=None):
        """
        Initialize ThemeManager.

        Args:
            theme_dir (str): Path to KlipperScreen/styles directory
            cache: Optional AssetCache instance
        """
        self.theme_dir = Path(theme_dir)
        self.cache = cache
        self.current_theme = None

        if not self.theme_dir.exists():
            raise ThemeNotFoundError(f"Theme directory not found: {theme_dir}")

    def loadTheme(self, theme_name: str):
        """
        Load specified theme with all assets.
        加载指定主题的所有素材。

        Args:
            theme_name (str): Theme name (material-dark, etc.)

        Returns:
            Theme: Loaded theme object

        Raises:
            ThemeNotFoundError: Theme directory not found
            ThemeLoadError: Theme loading failed
        """
        import time
        from .css_parser import GTKCSSColorResolver
        from .models.theme import Theme
        from .models.color_palette import ColorPalette

        start_time = time.time()

        if theme_name not in self.VALID_THEMES:
            raise ValueError(f"Invalid theme name: {theme_name}")

        theme_path = self.theme_dir / theme_name
        if not theme_path.exists():
            raise ThemeNotFoundError(f"Theme not found: {theme_name}")

        logger.info(f"Loading theme: {theme_name}")

        try:
            # Parse CSS colors
            colors = self._parse_theme_css(theme_path)

            # Create theme object
            from .models.theme import Theme
            theme = Theme(
                name=theme_name,
                base_dir=theme_path,
                colors=colors,
                icons_dir=theme_path / "images",
                css_file=theme_path / "style.css",
                base_css_file=self.theme_dir / "base.css"
            )

            # Scan icons directory (optional, for caching metadata)
            if theme.icons_dir and theme.icons_dir.exists():
                icon_count = len(list(theme.icons_dir.glob("*.svg")))
                logger.debug(f"Found {icon_count} SVG icons in theme")

            self.current_theme = theme

            elapsed = (time.time() - start_time) * 1000
            logger.info(f"Theme loaded successfully: {theme_name} ({elapsed:.2f}ms)")

            return theme

        except Exception as e:
            raise ThemeLoadError(f"Failed to load theme {theme_name}: {e}") from e

    def _parse_theme_css(self, theme_path: Path):
        """
        Parse theme CSS files and merge colors.
        解析主题 CSS 文件并合并颜色。

        Args:
            theme_path (Path): Theme directory path

        Returns:
            ColorPalette: Merged color palette
        """
        from .css_parser import GTKCSSColorResolver
        from .models.color_palette import ColorPalette

        parser = GTKCSSColorResolver()
        merged_colors = {}

        # Parse base.css first
        base_css = self.theme_dir / "base.css"
        if base_css.exists():
            logger.debug(f"Parsing base CSS: {base_css}")
            base_colors = parser.parse_file(str(base_css))
            merged_colors.update(base_colors)

        # Parse theme-specific style.css (overrides base)
        theme_css = theme_path / "style.css"
        if theme_css.exists():
            logger.debug(f"Parsing theme CSS: {theme_css}")
            theme_colors = parser.parse_file(str(theme_css))
            merged_colors.update(theme_colors)

        # Convert to ColorPalette
        try:
            palette = ColorPalette.from_dict(merged_colors)
        except Exception as e:
            logger.warning(f"Failed to parse some colors, using defaults: {e}")
            # Create default palette
            palette = ColorPalette()

        return palette

    def parseThemeColors(self, css_file_path: str):
        """
        Parse color definitions from CSS file.
        从 CSS 文件解析颜色定义。

        Args:
            css_file_path (str): Path to CSS file

        Returns:
            ColorPalette: Parsed colors
        """
        from .css_parser import GTKCSSColorResolver
        from .models.color_palette import ColorPalette

        parser = GTKCSSColorResolver()
        colors = parser.parse_file(css_file_path)

        return ColorPalette.from_dict(colors)

    def listAvailableThemes(self) -> List[str]:
        """
        List all available themes.
        列出所有可用主题。

        Returns:
            List[str]: Theme names
        """
        available = []
        for theme_name in self.VALID_THEMES:
            theme_path = self.theme_dir / theme_name
            if theme_path.exists():
                available.append(theme_name)

        logger.debug(f"Available themes: {available}")
        return available

    def reloadCurrentTheme(self) -> None:
        """
        Reload current theme.
        重新加载当前主题。
        """
        if self.current_theme:
            if self.cache:
                self.cache.clear()
            self.loadTheme(self.current_theme.name)
