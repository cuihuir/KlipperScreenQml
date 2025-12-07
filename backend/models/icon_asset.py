# Icon Asset Data Model
# 图标素材数据模型
"""
IconAsset represents a loaded SVG icon with metadata.

图标素材表示已加载的 SVG 图标及其元数据。
"""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional
import time


@dataclass
class IconAsset:
    """
    Represents a loaded icon asset with caching metadata.
    表示已加载的图标素材及缓存元数据。
    """

    # Icon identification / 图标标识
    name: str                           # Icon name (without extension)
    file_path: Path                     # Absolute path to icon file

    # Icon data / 图标数据
    format: str = "svg"                 # Icon format (svg, png)
    svg_data: Optional[str] = None      # SVG file content (if loaded)

    # Caching metadata / 缓存元数据
    cached_time: float = field(default_factory=time.time)  # When cached
    file_size: int = 0                  # File size in bytes

    def __post_init__(self):
        """Validate icon asset after initialization."""
        self._validate()

    def _validate(self):
        """
        Validate icon asset data.
        验证图标素材数据。

        Raises:
            ValueError: If validation fails
        """
        if not self.name:
            raise ValueError("Icon name cannot be empty")

        if not isinstance(self.file_path, Path):
            raise ValueError(f"file_path must be a Path object, got {type(self.file_path)}")

        if self.format not in ['svg', 'png']:
            raise ValueError(f"Unsupported icon format: {self.format}")

    @property
    def exists(self) -> bool:
        """
        Check if icon file exists.
        检查图标文件是否存在。

        Returns:
            bool: True if file exists
        """
        return self.file_path.exists()

    @property
    def url(self) -> str:
        """
        Get file:// URL for QML.
        获取用于 QML 的 file:// URL。

        Returns:
            str: file:// URL
        """
        return f"file://{self.file_path.absolute()}"

    @property
    def is_cached(self) -> bool:
        """
        Check if icon is considered cached.
        检查图标是否被视为已缓存。

        Returns:
            bool: True if cached (has svg_data or recent cached_time)
        """
        return self.svg_data is not None

    def load_svg_data(self) -> None:
        """
        Load SVG file content into memory.
        将 SVG 文件内容加载到内存。

        Raises:
            FileNotFoundError: If icon file doesn't exist
        """
        if not self.exists:
            raise FileNotFoundError(f"Icon file not found: {self.file_path}")

        if self.format == 'svg':
            with open(self.file_path, 'r', encoding='utf-8') as f:
                self.svg_data = f.read()

            # Update file size
            self.file_size = len(self.svg_data.encode('utf-8'))

    def get_estimated_size(self) -> int:
        """
        Get estimated memory size.
        获取估算的内存大小。

        Returns:
            int: Estimated size in bytes
        """
        if self.svg_data:
            return len(self.svg_data.encode('utf-8'))
        elif self.file_size > 0:
            return self.file_size
        else:
            # Default estimate for SVG icon
            return 10 * 1024  # 10KB

    def __repr__(self) -> str:
        """String representation for debugging."""
        return (
            f"IconAsset(name='{self.name}', format='{self.format}', "
            f"exists={self.exists}, cached={self.is_cached})"
        )
