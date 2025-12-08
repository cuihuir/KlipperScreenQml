# Asset Cache for QtKs
# 素材缓存 - LRU 缓存管理图标素材
"""
AssetCache manages icon asset caching with LRU eviction policy.

素材缓存使用 LRU 淘汰策略管理图标素材。
"""

from typing import Optional, Dict
from collections import OrderedDict
import time
import logging

logger = logging.getLogger(__name__)


class AssetCache:
    """
    LRU cache for icon assets.
    图标素材的 LRU 缓存。
    """

    def __init__(self, max_cache_size: int = 20 * 1024 * 1024):
        """
        Initialize AssetCache.

        Args:
            max_cache_size (int): Maximum cache size in bytes (default: 20MB)
        """
        self.max_cache_size = max_cache_size
        self.cached_icons: OrderedDict = OrderedDict()
        self.access_times: Dict[str, float] = {}
        self.cache_size_bytes = 0

        logger.info(f"AssetCache initialized with max size: {max_cache_size / 1024 / 1024}MB")

    def get(self, icon_name: str):
        """
        Get icon and update access time.
        获取图标并更新访问时间。

        Args:
            icon_name (str): Icon name

        Returns:
            Optional[IconAsset]: Icon object or None
        """
        if icon_name in self.cached_icons:
            # Update access time for LRU
            self.access_times[icon_name] = time.time()
            # Move to end (most recently used)
            self.cached_icons.move_to_end(icon_name)
            logger.debug(f"Cache hit: {icon_name}")
            return self.cached_icons[icon_name]

        logger.debug(f"Cache miss: {icon_name}")
        return None

    def set(self, icon_name: str, icon) -> None:
        """
        Add icon to cache, evict if necessary.
        添加图标到缓存，必要时淘汰。

        Args:
            icon_name (str): Icon name
            icon: Icon object
        """
        # Estimate icon size (simplified)
        icon_size = self._estimate_size(icon)

        # Evict old entries if necessary
        while (self.cache_size_bytes + icon_size > self.max_cache_size and
               len(self.cached_icons) > 0):
            self.evict_lru()

        # Add to cache
        self.cached_icons[icon_name] = icon
        self.access_times[icon_name] = time.time()
        self.cache_size_bytes += icon_size

        logger.debug(f"Cached icon: {icon_name} ({icon_size} bytes)")

    def evict_lru(self) -> None:
        """
        Evict least recently used icon.
        淘汰最久未使用的图标。
        """
        if not self.cached_icons:
            return

        # Get least recently used item (first item in OrderedDict)
        lru_name, lru_icon = self.cached_icons.popitem(last=False)

        # Update cache size
        icon_size = self._estimate_size(lru_icon)
        self.cache_size_bytes -= icon_size

        # Remove access time
        del self.access_times[lru_name]

        logger.debug(f"Evicted LRU icon: {lru_name}")

    def clear(self) -> None:
        """
        Clear all cached icons.
        清空所有缓存。
        """
        self.cached_icons.clear()
        self.access_times.clear()
        self.cache_size_bytes = 0
        logger.info("Cache cleared")

    @property
    def cache_usage_percent(self) -> float:
        """
        Cache usage percentage.
        缓存使用百分比。

        Returns:
            float: Usage percentage (0-100)
        """
        if self.max_cache_size == 0:
            return 0.0

        return (self.cache_size_bytes / self.max_cache_size) * 100

    def getStats(self) -> Dict:
        """
        Get cache statistics.
        获取缓存统计信息。

        Returns:
            Dict: Cache statistics (hits, misses, entries, size, etc.)
        """
        # Calculate hit/miss counts from access patterns
        total_accesses = len(self.access_times)
        hits = sum(1 for _ in self.cached_icons.keys())

        return {
            "entries": len(self.cached_icons),
            "size_bytes": self.cache_size_bytes,
            "size_mb": round(self.cache_size_bytes / 1024 / 1024, 2),
            "max_size_bytes": self.max_cache_size,
            "max_size_mb": round(self.max_cache_size / 1024 / 1024, 2),
            "usage_percent": round(self.cache_usage_percent, 2),
            "hits": hits,
            "misses": max(0, total_accesses - hits),
            "total_accesses": total_accesses
        }

    def _estimate_size(self, icon) -> int:
        """
        Estimate icon memory size.
        估算图标内存占用。

        Args:
            icon: Icon object

        Returns:
            int: Estimated size in bytes
        """
        # Simplified estimation: ~10KB per icon on average
        # TODO: Implement accurate size calculation based on IconAsset
        return 10 * 1024
