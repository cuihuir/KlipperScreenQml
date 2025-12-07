# 数据模型：KlipperScreen UI 素材集成 / Data Model: KlipperScreen UI Assets Integration

**分支 / Branch**: `002-ui-assets`
**日期 / Date**: 2025-12-07

## 概述 / Overview

本文档定义 QtKs UI 素材系统的核心数据实体、字段、关系和验证规则。所有实体均从功能规范中提取，遵循 Python 数据类和 QML QtObject 模式。

This document defines core data entities, fields, relationships, and validation rules for the QtKs UI assets system. All entities extracted from feature specification, following Python dataclass and QML QtObject patterns.

---

## 实体关系图 / Entity Relationship Diagram

```
┌─────────────────────┐
│ ThemeConfiguration  │
│  (配置层)           │
└──────────┬──────────┘
           │ 1
           │ has
           │
           ▼ 1
┌─────────────────────┐       ┌─────────────────────┐
│      Theme          │ 1   1 │   ColorPalette      │
│   (主题实体)        │◄──────┤  (颜色调色板)       │
└──────────┬──────────┘  has  └─────────────────────┘
           │
           │ 1
           │ has-many
           │
           ▼ *
┌─────────────────────┐       ┌─────────────────────┐
│     IconAsset       │       │    AssetCache       │
│   (图标素材)        │◄──────┤   (素材缓存)        │
└─────────────────────┘  uses └─────────────────────┘
```

---

## 实体 1: Theme / 主题

### 描述 / Description

表示一个完整的视觉主题，包含颜色调色板和图标集合。KlipperScreen 提供 5 个内置主题：material-dark, material-darker, material-light, colorized, z-bolt。

Represents a complete visual theme including color palette and icon collection. KlipperScreen provides 5 built-in themes.

### 字段 / Fields

| 字段名 Field | 类型 Type | 必需 Required | 描述 Description |
|-------------|----------|--------------|------------------|
| `name` | `str` | ✅ | 主题名称，如 "material-dark" |
| `base_dir` | `Path` | ✅ | 主题根目录路径，如 `KlipperScreen/styles/material-dark` |
| `colors` | `ColorPalette` | ✅ | 主题颜色调色板 |
| `icons_dir` | `Path` | ✅ | 图标目录路径，如 `{base_dir}/images` |
| `icons` | `Dict[str, IconAsset]` | ✅ | 图标名称到 IconAsset 的映射 |
| `css_file` | `Path` | ⚪ | 主题 CSS 文件路径，如 `{base_dir}/style.css` |
| `conf_file` | `Path` | ⚪ | 主题配置文件路径，如 `{base_dir}/style.conf` |

### 关系 / Relationships

- **has-one ColorPalette**: 一个主题有一个颜色调色板
- **has-many IconAsset**: 一个主题有多个图标（100+）

### 验证规则 / Validation Rules

```python
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Optional

@dataclass
class Theme:
    name: str
    base_dir: Path
    colors: 'ColorPalette'
    icons_dir: Path
    icons: Dict[str, 'IconAsset']
    css_file: Optional[Path] = None
    conf_file: Optional[Path] = None

    def __post_init__(self):
        # 验证主题名称
        valid_themes = {
            'material-dark', 'material-darker', 'material-light',
            'colorized', 'z-bolt', 'base'
        }
        if self.name not in valid_themes:
            raise ValueError(
                f"Invalid theme name '{self.name}'. "
                f"Must be one of {valid_themes}"
            )

        # 验证目录存在
        if not self.base_dir.exists():
            raise FileNotFoundError(f"Theme directory not found: {self.base_dir}")

        if not self.icons_dir.exists():
            raise FileNotFoundError(f"Icons directory not found: {self.icons_dir}")

        # 验证至少有一些图标
        if len(self.icons) == 0:
            raise ValueError(f"Theme '{self.name}' has no icons")

    @property
    def icon_count(self) -> int:
        """返回图标数量"""
        return len(self.icons)

    def get_icon(self, name: str) -> Optional['IconAsset']:
        """获取指定名称的图标"""
        return self.icons.get(name)
```

---

## 实体 2: ColorPalette / 颜色调色板

### 描述 / Description

存储主题的所有颜色定义，包括主题色、语义色和文字色。从 KlipperScreen CSS 文件的 `@define-color` 定义中解析。

Stores all color definitions for a theme, including primary colors, semantic colors, and text colors. Parsed from KlipperScreen CSS `@define-color` definitions.

### 字段 / Fields

**主题色 / Primary Colors:**

| 字段名 Field | 类型 Type | 必需 | 默认值 Default | 描述 Description |
|-------------|----------|------|---------------|------------------|
| `color1` | `str` | ✅ | `"#ED6500"` | 主题色 1 - 橙色 (Orange) |
| `color2` | `str` | ✅ | `"#B10080"` | 主题色 2 - 紫红 (Magenta) |
| `color3` | `str` | ✅ | `"#009384"` | 主题色 3 - 青色 (Teal) |
| `color4` | `str` | ✅ | `"#A7E100"` | 主题色 4 - 黄绿 (Lime) |

**语义色 / Semantic Colors:**

| 字段名 Field | 类型 Type | 必需 | 默认值 Default | 描述 Description |
|-------------|----------|------|---------------|------------------|
| `bg` | `str` | ✅ | `"#13181C"` | 背景色 (Background) |
| `active` | `str` | ✅ | `"#404E57"` | 激活状态色 (Active state) |
| `echo` | `str` | ✅ | `"#367554"` | 回显/确认色 (Echo/Confirm) |
| `warning` | `str` | ✅ | `"#F9A825"` | 警告色 (Warning) |
| `error` | `str` | ✅ | `"#981E1F"` | 错误色 (Error) |

**文字色 / Text Colors:**

| 字段名 Field | 类型 Type | 必需 | 默认值 Default | 描述 Description |
|-------------|----------|------|---------------|------------------|
| `text` | `str` | ✅ | `"#FFFFFF"` | 主文字色 (Primary text) |
| `text_inv` | `str` | ✅ | `"#000000"` | 反转文字色 (Inverted text) |
| `lines` | `str` | ✅ | `"#CCCCCC"` | 线条/边框色 (Lines/Borders) |
| `switch_scale_bg` | `str` | ⚪ | `"#3584E4"` | 开关背景色 (Switch background) |

### 来源 / Source

解析自 KlipperScreen CSS 文件：
- `KlipperScreen/styles/base.css` - 基础颜色定义
- `KlipperScreen/styles/{theme}/style.css` - 主题颜色覆盖

### 验证规则 / Validation Rules

```python
import re
from dataclasses import dataclass, field

@dataclass
class ColorPalette:
    """颜色调色板"""

    # 主题色
    color1: str = "#ED6500"
    color2: str = "#B10080"
    color3: str = "#009384"
    color4: str = "#A7E100"

    # 语义色
    bg: str = "#13181C"
    active: str = "#404E57"
    echo: str = "#367554"
    warning: str = "#F9A825"
    error: str = "#981E1F"

    # 文字色
    text: str = "#FFFFFF"
    text_inv: str = "#000000"
    lines: str = "#CCCCCC"
    switch_scale_bg: str = "#3584E4"

    def __post_init__(self):
        """验证所有颜色值格式"""
        color_pattern = re.compile(r'^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$')

        for field_name, value in self.__dict__.items():
            if not color_pattern.match(value):
                raise ValueError(
                    f"Invalid color format for '{field_name}': {value}. "
                    f"Must be #RRGGBB or #AARRGGBB"
                )

            # 转换为大写
            setattr(self, field_name, value.upper())

    def to_dict(self) -> Dict[str, str]:
        """转换为字典格式"""
        return {
            'color1': self.color1,
            'color2': self.color2,
            'color3': self.color3,
            'color4': self.color4,
            'bg': self.bg,
            'active': self.active,
            'echo': self.echo,
            'warning': self.warning,
            'error': self.error,
            'text': self.text,
            'textInv': self.text_inv,
            'lines': self.lines,
            'switchScaleBg': self.switch_scale_bg,
        }

    def to_qml_properties(self) -> str:
        """生成 QML 属性定义"""
        props = []
        for name, value in self.to_dict().items():
            props.append(f'    readonly property color {name}: "{value}"')
        return '\n'.join(props)
```

---

## 实体 3: IconAsset / 图标素材

### 描述 / Description

表示单个图标文件，包含文件路径、SVG 数据（可选缓存）、格式和元数据。

Represents a single icon file with path, SVG data (optionally cached), format, and metadata.

### 字段 / Fields

| 字段名 Field | 类型 Type | 必需 | 描述 Description |
|-------------|----------|------|------------------|
| `name` | `str` | ✅ | 图标名称（不含扩展名），如 "home" |
| `file_path` | `Path` | ✅ | 图标文件绝对路径 |
| `format` | `str` | ✅ | 文件格式："svg" 或 "png" |
| `size_hint` | `Optional[Tuple[int, int]]` | ⚪ | 建议渲染尺寸 (width, height) |
| `svg_data` | `Optional[str]` | ⚪ | 缓存的 SVG 文件内容（仅 SVG 格式） |
| `cached_time` | `Optional[datetime]` | ⚪ | 缓存时间戳 |

### 缓存状态 / Cache State

```python
from enum import Enum

class IconLoadState(Enum):
    """图标加载状态"""
    NOT_LOADED = "not_loaded"      # 未加载
    LOADING = "loading"             # 加载中
    LOADED = "loaded"               # 已加载到缓存
    ERROR = "error"                 # 加载失败
```

### 验证规则 / Validation Rules

```python
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Optional, Tuple
from enum import Enum

class IconLoadState(Enum):
    NOT_LOADED = "not_loaded"
    LOADING = "loading"
    LOADED = "loaded"
    ERROR = "error"

@dataclass
class IconAsset:
    """图标素材"""

    name: str
    file_path: Path
    format: str
    size_hint: Optional[Tuple[int, int]] = None
    svg_data: Optional[str] = None
    cached_time: Optional[datetime] = None
    _load_state: IconLoadState = IconLoadState.NOT_LOADED

    def __post_init__(self):
        # 验证文件存在
        if not self.file_path.exists():
            raise FileNotFoundError(f"Icon file not found: {self.file_path}")

        # 验证格式
        if self.format not in ('svg', 'png'):
            raise ValueError(
                f"Invalid format '{self.format}'. Must be 'svg' or 'png'"
            )

        # 验证文件扩展名与格式匹配
        expected_ext = f".{self.format}"
        if self.file_path.suffix.lower() != expected_ext:
            raise ValueError(
                f"File extension '{self.file_path.suffix}' doesn't match "
                f"format '{self.format}'"
            )

    @property
    def is_cached(self) -> bool:
        """是否已缓存"""
        return self._load_state == IconLoadState.LOADED

    @property
    def is_svg(self) -> bool:
        """是否为 SVG 格式"""
        return self.format == 'svg'

    @property
    def file_url(self) -> str:
        """返回 file:// URL 格式路径"""
        return f"file://{self.file_path.as_posix()}"

    @property
    def qrc_url(self) -> str:
        """返回 qrc:// URL 格式路径（假设在资源系统中）"""
        # 从 KlipperScreen/styles/... 提取相对路径
        parts = self.file_path.parts
        if 'KlipperScreen' in parts:
            idx = parts.index('KlipperScreen')
            relative = Path(*parts[idx+1:])
            return f"qrc:/{relative.as_posix()}"
        return self.file_url

    def load_data(self) -> bool:
        """加载 SVG 数据到内存"""
        if not self.is_svg:
            return False

        try:
            self._load_state = IconLoadState.LOADING
            with open(self.file_path, 'r', encoding='utf-8') as f:
                self.svg_data = f.read()
            self.cached_time = datetime.now()
            self._load_state = IconLoadState.LOADED
            return True
        except Exception as e:
            self._load_state = IconLoadState.ERROR
            raise RuntimeError(f"Failed to load icon {self.name}: {e}")

    def clear_cache(self):
        """清除缓存数据"""
        self.svg_data = None
        self.cached_time = None
        self._load_state = IconLoadState.NOT_LOADED
```

---

## 实体 4: AssetCache / 素材缓存

### 描述 / Description

管理图标素材的内存缓存，使用 LRU（最近最少使用）策略自动淘汰，限制最大缓存大小为 20MB。

Manages in-memory cache of icon assets with LRU (Least Recently Used) eviction strategy, limited to 20MB max size.

### 字段 / Fields

| 字段名 Field | 类型 Type | 必需 | 描述 Description |
|-------------|----------|------|------------------|
| `cached_icons` | `Dict[str, IconAsset]` | ✅ | 图标名称到 IconAsset 的映射 |
| `access_times` | `Dict[str, datetime]` | ✅ | 访问时间戳（用于 LRU） |
| `cache_size_bytes` | `int` | ✅ | 当前缓存大小（字节） |
| `max_cache_size` | `int` | ✅ | 最大缓存大小（字节），默认 20MB |

### 操作 / Operations

```python
def get(icon_name: str) -> Optional[IconAsset]:
    """获取图标，更新访问时间"""

def set(icon_name: str, icon: IconAsset) -> None:
    """添加图标到缓存，必要时淘汰"""

def evict_lru() -> None:
    """淘汰最久未使用的图标"""

def clear() -> None:
    """清空所有缓存"""
```

### 约束 / Constraints

- `cache_size_bytes <= max_cache_size`（自动淘汰确保）
- LRU 淘汰策略：当超过限制时，移除最久未访问的图标

### 实现 / Implementation

```python
from collections import OrderedDict
from dataclasses import dataclass, field
from datetime import datetime
from typing import Dict, Optional

@dataclass
class AssetCache:
    """素材缓存管理器"""

    max_cache_size: int = 20 * 1024 * 1024  # 20MB
    cached_icons: Dict[str, IconAsset] = field(default_factory=dict)
    access_times: Dict[str, datetime] = field(default_factory=dict)
    cache_size_bytes: int = 0

    def get(self, icon_name: str) -> Optional[IconAsset]:
        """获取图标并更新访问时间"""
        if icon_name in self.cached_icons:
            self.access_times[icon_name] = datetime.now()
            return self.cached_icons[icon_name]
        return None

    def set(self, icon_name: str, icon: IconAsset) -> None:
        """添加图标到缓存"""
        # 计算图标大小
        icon_size = self._estimate_size(icon)

        # 淘汰直到有足够空间
        while self.cache_size_bytes + icon_size > self.max_cache_size:
            if not self.cached_icons:
                break
            self.evict_lru()

        # 添加到缓存
        self.cached_icons[icon_name] = icon
        self.access_times[icon_name] = datetime.now()
        self.cache_size_bytes += icon_size

    def evict_lru(self) -> None:
        """淘汰最久未使用的图标"""
        if not self.access_times:
            return

        # 找到最久未访问的图标
        lru_name = min(self.access_times, key=self.access_times.get)

        # 移除
        icon = self.cached_icons.pop(lru_name)
        self.access_times.pop(lru_name)
        self.cache_size_bytes -= self._estimate_size(icon)

    def clear(self) -> None:
        """清空所有缓存"""
        self.cached_icons.clear()
        self.access_times.clear()
        self.cache_size_bytes = 0

    @property
    def cache_usage_percent(self) -> float:
        """缓存使用百分比"""
        return (self.cache_size_bytes / self.max_cache_size) * 100

    @staticmethod
    def _estimate_size(icon: IconAsset) -> int:
        """估算图标占用内存"""
        if icon.svg_data:
            # SVG: 文本数据大小
            return len(icon.svg_data.encode('utf-8'))
        elif icon.size_hint:
            # PNG: width * height * 4 (RGBA)
            w, h = icon.size_hint
            return w * h * 4
        else:
            # 默认估计: 48x48 RGBA
            return 48 * 48 * 4
```

---

## 实体 5: ThemeConfiguration / 主题配置

### 描述 / Description

存储应用的主题配置，包括选中的主题、路径、回退主题和自定义图标设置。从 `config.json` 或 `KlipperScreen.conf` 解析。

Stores application theme configuration including selected theme, paths, fallback theme, and custom icon settings. Parsed from `config.json` or `KlipperScreen.conf`.

### 字段 / Fields

| 字段名 Field | 类型 Type | 必需 | 默认值 Default | 描述 Description |
|-------------|----------|------|---------------|------------------|
| `selected_theme` | `str` | ✅ | `"material-dark"` | 当前选中的主题名称 |
| `theme_dir` | `Path` | ✅ | `Path("KlipperScreen/styles")` | 主题根目录 |
| `fallback_theme` | `str` | ✅ | `"base"` | 回退主题（加载失败时使用） |
| `custom_icons_enabled` | `bool` | ⚪ | `False` | 是否启用自定义图标 |
| `custom_icons_dir` | `Optional[Path]` | ⚪ | `None` | 自定义图标目录 |

### 来源 / Source

优先级（从高到低）：
1. `config.json` - 应用配置文件
2. `KlipperScreen.conf` - KlipperScreen 配置文件
3. 默认值

### 验证规则 / Validation Rules

```python
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

@dataclass
class ThemeConfiguration:
    """主题配置"""

    selected_theme: str = "material-dark"
    theme_dir: Path = Path("KlipperScreen/styles")
    fallback_theme: str = "base"
    custom_icons_enabled: bool = False
    custom_icons_dir: Optional[Path] = None

    def __post_init__(self):
        # 验证主题目录存在
        if not self.theme_dir.exists():
            raise FileNotFoundError(
                f"Theme directory not found: {self.theme_dir}"
            )

        # 验证选中的主题存在
        selected_path = self.theme_dir / self.selected_theme
        if not selected_path.exists():
            raise ValueError(
                f"Selected theme '{self.selected_theme}' not found in "
                f"{self.theme_dir}"
            )

        # 验证回退主题存在
        fallback_path = self.theme_dir / self.fallback_theme
        if not fallback_path.exists():
            raise ValueError(
                f"Fallback theme '{self.fallback_theme}' not found in "
                f"{self.theme_dir}"
            )

        # 验证自定义图标目录（如果启用）
        if self.custom_icons_enabled and self.custom_icons_dir:
            if not self.custom_icons_dir.exists():
                raise FileNotFoundError(
                    f"Custom icons directory not found: {self.custom_icons_dir}"
                )

    @property
    def selected_theme_path(self) -> Path:
        """返回选中主题的完整路径"""
        return self.theme_dir / self.selected_theme

    @property
    def fallback_theme_path(self) -> Path:
        """返回回退主题的完整路径"""
        return self.theme_dir / self.fallback_theme

    @classmethod
    def from_dict(cls, config: Dict[str, Any]) -> 'ThemeConfiguration':
        """从字典创建配置"""
        return cls(
            selected_theme=config.get('selected_theme', 'material-dark'),
            theme_dir=Path(config.get('theme_dir', 'KlipperScreen/styles')),
            fallback_theme=config.get('fallback_theme', 'base'),
            custom_icons_enabled=config.get('custom_icons_enabled', False),
            custom_icons_dir=Path(config['custom_icons_dir'])
                if 'custom_icons_dir' in config else None
        )

    def to_dict(self) -> Dict[str, Any]:
        """转换为字典"""
        result = {
            'selected_theme': self.selected_theme,
            'theme_dir': str(self.theme_dir),
            'fallback_theme': self.fallback_theme,
            'custom_icons_enabled': self.custom_icons_enabled,
        }
        if self.custom_icons_dir:
            result['custom_icons_dir'] = str(self.custom_icons_dir)
        return result
```

---

## 数据流 / Data Flow

### 主题加载流程 / Theme Loading Flow

```
1. 应用启动 (Application Startup)
   ↓
2. 加载 ThemeConfiguration (从 config.json)
   ↓
3. ThemeManager.load_theme(config.selected_theme)
   ├─ 解析 CSS 文件 → ColorPalette
   ├─ 扫描图标目录 → List[IconAsset]
   └─ 创建 Theme 对象
   ↓
4. 暴露给 QML (ThemeProvider QObject)
   ├─ colors (ColorPalette 属性)
   └─ getIconPath(name) 方法
   ↓
5. QML Image 组件加载图标
   ↓
6. AssetCache 缓存管理
```

### 图标加载流程 / Icon Loading Flow

```
QML Image.source = "qrc:/assets/icons/home.svg"
   ↓
1. AssetCache.get("home")
   ├─ 已缓存? → 返回 IconAsset ✓
   └─ 未缓存? → 继续 ↓
   ↓
2. IconLoader.load_icon("home", current_theme)
   ├─ 查找文件: {theme}/images/home.svg
   ├─ 创建 IconAsset
   ├─ IconAsset.load_data() (SVG)
   └─ AssetCache.set("home", icon)
   ↓
3. 返回 IconAsset.file_url
   ↓
4. QML Image 渲染
```

---

## QML 数据绑定 / QML Data Binding

### ThemeProvider QObject

```python
from PySide6.QtCore import QObject, Property, Signal, Slot

class ThemeProvider(QObject):
    """QML 主题提供者"""

    themeChanged = Signal()

    def __init__(self, theme: Theme):
        super().__init__()
        self._theme = theme

    @Property(str, notify=themeChanged)
    def currentTheme(self) -> str:
        return self._theme.name

    @Property(str, notify=themeChanged)
    def backgroundColor(self) -> str:
        return self._theme.colors.bg

    @Property(str, notify=themeChanged)
    def textColor(self) -> str:
        return self._theme.colors.text

    # ... 其他颜色属性

    @Slot(str, result=str)
    def getIconPath(self, icon_name: str) -> str:
        """获取图标路径"""
        icon = self._theme.get_icon(icon_name)
        return icon.file_url if icon else ""
```

### QML 使用示例

```qml
import QtQuick

Rectangle {
    color: ThemeProvider.backgroundColor

    Image {
        source: ThemeProvider.getIconPath("home")
        width: 48
        height: 48
    }

    Text {
        color: ThemeProvider.textColor
        text: "Hello"
    }
}
```

---

## 总结 / Summary

**核心实体 / Core Entities**: 5 个
- Theme（主题）
- ColorPalette（颜色调色板）
- IconAsset（图标素材）
- AssetCache（素材缓存）
- ThemeConfiguration（主题配置）

**关键关系 / Key Relationships**:
- ThemeConfiguration → Theme (1:1)
- Theme → ColorPalette (1:1)
- Theme → IconAsset (1:N)
- AssetCache → IconAsset (N:M)

**数据来源 / Data Sources**:
- CSS 文件 (`@define-color`)
- SVG/PNG 文件（图标）
- 配置文件 (`config.json`, `KlipperScreen.conf`)

**下一步 / Next Steps**:
→ 定义 API 契约 (contracts/theme-api.yaml)
→ 编写快速启动指南 (quickstart.md)
