# Icon Loader for QtKs
# 图标加载器 - 加载和缓存 SVG 图标
"""
IconLoader handles loading SVG icons from KlipperScreen themes with caching.

图标加载器处理从 KlipperScreen 主题加载 SVG 图标并缓存。
"""

from pathlib import Path
from typing import Optional, List
import logging
import time

from .models.icon_asset import IconAsset
from .models.theme import Theme

logger = logging.getLogger(__name__)


class IconNotFoundError(Exception):
    """图标文件不存在 / Icon file not found"""
    pass


class IconLoader:
    """
    Loads and caches SVG icons from KlipperScreen themes.
    从 KlipperScreen 主题加载和缓存 SVG 图标。
    """

    # Supported icon extensions / 支持的图标扩展名
    ICON_EXTENSIONS = ['.svg', '.png']

    def __init__(self, cache=None):
        """
        Initialize IconLoader.

        Args:
            cache: Optional AssetCache instance
        """
        self.cache = cache
        self._placeholder_icon = None

    def loadIcon(self, icon_name: str, theme: Theme) -> IconAsset:
        """
        Load specified icon, prefer cache.
        加载指定图标，优先使用缓存。

        Args:
            icon_name (str): Icon name (without extension)
            theme (Theme): Current theme object

        Returns:
            IconAsset: Icon object or fallback placeholder

        Raises:
            IconNotFoundError: If icon not found and no fallback available
        """
        start_time = time.time()

        # Check cache first
        if self.cache:
            cached = self.cache.get(icon_name)
            if cached:
                elapsed = (time.time() - start_time) * 1000
                logger.debug(f"Icon cache hit: {icon_name} ({elapsed:.2f}ms)")
                return cached

        # Try loading from theme with fallback chain
        icon_asset = self._load_with_fallback(icon_name, theme)

        # Cache the loaded icon
        if self.cache and icon_asset:
            self.cache.set(icon_name, icon_asset)

        elapsed = (time.time() - start_time) * 1000
        if elapsed > 50:
            logger.warning(f"Icon load time exceeded 50ms: {icon_name} ({elapsed:.2f}ms)")
        else:
            logger.debug(f"Icon loaded: {icon_name} ({elapsed:.2f}ms)")

        return icon_asset

    def _load_with_fallback(self, icon_name: str, theme: Theme) -> Optional[IconAsset]:
        """
        Load icon with fallback chain.
        使用回退链加载图标。

        Fallback priority:
        1. Current theme icons directory
        2. Base theme icons directory
        3. Default placeholder icon

        Args:
            icon_name (str): Icon name
            theme (Theme): Current theme

        Returns:
            Optional[IconAsset]: Icon asset or None
        """
        # Priority 1: Current theme icons directory
        if theme.icons_dir and theme.icons_dir.exists():
            icon_path = self._find_icon_file(icon_name, theme.icons_dir)
            if icon_path:
                return self._create_icon_asset(icon_name, icon_path)

        # Priority 2: Base theme icons directory
        base_theme_dir = theme.base_dir.parent / "base" / "images"
        if base_theme_dir.exists() and base_theme_dir != theme.icons_dir:
            icon_path = self._find_icon_file(icon_name, base_theme_dir)
            if icon_path:
                logger.info(f"Using base theme icon for: {icon_name}")
                return self._create_icon_asset(icon_name, icon_path)

        # Priority 3: Placeholder icon
        logger.warning(f"Icon not found, using placeholder: {icon_name}")
        return self._get_placeholder_icon(icon_name)

    def _find_icon_file(self, icon_name: str, search_dir: Path) -> Optional[Path]:
        """
        Find icon file in directory.
        在目录中查找图标文件。

        Args:
            icon_name (str): Icon name (without extension)
            search_dir (Path): Directory to search

        Returns:
            Optional[Path]: Icon file path or None
        """
        for ext in self.ICON_EXTENSIONS:
            icon_path = search_dir / f"{icon_name}{ext}"
            if icon_path.exists():
                return icon_path

        return None

    def _create_icon_asset(self, icon_name: str, icon_path: Path) -> IconAsset:
        """
        Create IconAsset from file path.
        从文件路径创建 IconAsset。

        Args:
            icon_name (str): Icon name
            icon_path (Path): Icon file path

        Returns:
            IconAsset: Created icon asset
        """
        # Determine format from extension
        format_type = icon_path.suffix[1:]  # Remove leading dot

        icon = IconAsset(
            name=icon_name,
            file_path=icon_path,
            format=format_type,
            file_size=icon_path.stat().st_size if icon_path.exists() else 0
        )

        return icon

    def _get_placeholder_icon(self, icon_name: str) -> IconAsset:
        """
        Get or create placeholder icon.
        获取或创建占位符图标。

        Args:
            icon_name (str): Icon name (for reference)

        Returns:
            IconAsset: Placeholder icon
        """
        if self._placeholder_icon is None:
            # Create a simple placeholder (empty SVG path for now)
            placeholder_path = Path("/tmp/placeholder.svg")
            self._placeholder_icon = IconAsset(
                name="placeholder",
                file_path=placeholder_path,
                format="svg"
            )

        return self._placeholder_icon

    def preloadIcons(self, icon_names: List[str], theme: Theme) -> None:
        """
        Preload icon list to cache.
        预加载图标列表到缓存。

        Args:
            icon_names (List[str]): Icon names to preload
            theme (Theme): Current theme object
        """
        start_time = time.time()
        logger.info(f"Preloading {len(icon_names)} icons...")

        loaded_count = 0
        failed_count = 0

        for icon_name in icon_names:
            try:
                self.loadIcon(icon_name, theme)
                loaded_count += 1
            except Exception as e:
                logger.warning(f"Failed to preload icon {icon_name}: {e}")
                failed_count += 1

        elapsed = (time.time() - start_time) * 1000
        logger.info(
            f"Preload complete: {loaded_count} loaded, {failed_count} failed "
            f"({elapsed:.2f}ms)"
        )

    def getIconPath(self, icon_name: str, theme: Theme, format: str = "file") -> str:
        """
        Get icon path (URL format).
        获取图标路径（URL 格式）。

        Args:
            icon_name (str): Icon name
            theme (Theme): Current theme object
            format (str): Path format ("file" or "qrc")

        Returns:
            str: Icon URL path
        """
        # Load icon (will use cache if available)
        icon = self.loadIcon(icon_name, theme)

        if format == "file":
            return icon.url
        elif format == "qrc":
            # TODO: Implement qrc:// format
            return f"qrc:/assets/icons/{icon_name}.svg"
        else:
            raise ValueError(f"Unsupported format: {format}")
