# 快速启动指南：KlipperScreen UI 素材集成 / Quickstart Guide: KlipperScreen UI Assets Integration

**分支 / Branch**: `002-ui-assets`
**日期 / Date**: 2025-12-07
**目标读者 / Target Audience**: 开发者 / Developers

## 概述 / Overview

本指南帮助你快速集成 KlipperScreen 的 UI 素材（图标、主题、颜色）到 QtKs 项目中。

This guide helps you quickly integrate KlipperScreen UI assets (icons, themes, colors) into the QtKs project.

**预计完成时间 / Estimated Time**: 30 分钟 / 30 minutes

---

## 前置要求 / Prerequisites

```bash
# 系统要求 / System Requirements
Python >= 3.8
Qt >= 6.7
PySide6 >= 6.7.0

# 检查版本 / Check versions
python3 --version
pyside6-rcc --version
```

---

## 步骤 1: 开发环境设置 / Step 1: Development Setup

### 1.1 安装 PySide6 和依赖 / Install PySide6 and Dependencies

```bash
# 切换到项目目录 / Navigate to project directory
cd /home/tope/project_py/QtKs

# 创建虚拟环境（如果尚未创建）/ Create virtual environment (if not exists)
python3 -m venv .venv

# 激活虚拟环境 / Activate virtual environment
source .venv/bin/activate

# 安装依赖 / Install dependencies
pip install -r requirements.txt

# 或手动安装 / Or install manually
pip install PySide6>=6.7.0
```

### 1.2 验证 KlipperScreen 仓库 / Verify KlipperScreen Repository

```bash
# 检查 KlipperScreen 目录是否存在 / Check KlipperScreen directory exists
ls KlipperScreen/styles/

# 应该看到以下主题目录 / Should see following theme directories:
# base.css
# material-dark/
# material-darker/
# material-light/
# colorized/
# z-bolt/

# 检查图标数量 / Check icon count
ls KlipperScreen/styles/material-dark/images/*.svg | wc -l
# 应该显示 104 / Should show 104
```

### 1.3 配置主题路径 / Configure Theme Paths

编辑 `config.json`:

```json
{
  "theme": {
    "selected_theme": "material-dark",
    "theme_dir": "KlipperScreen/styles",
    "fallback_theme": "base",
    "custom_icons_enabled": false
  }
}
```

---

## 步骤 2: 主题使用示例 / Step 2: Theme Usage Examples

### 2.1 后端：加载主题 / Backend: Load Theme

创建 `backend/theme_manager.py`:

```python
from pathlib import Path
from typing import Dict
from backend.css_parser import GTKCSSColorResolver
from backend.icon_loader import IconLoader
from backend.asset_cache import AssetCache

class ThemeManager:
    """主题管理器"""

    def __init__(self, theme_dir: str = "KlipperScreen/styles"):
        self.theme_dir = Path(theme_dir)
        self.cache = AssetCache(max_cache_size=20 * 1024 * 1024)
        self.icon_loader = IconLoader(cache=self.cache)
        self.css_parser = GTKCSSColorResolver()
        self.current_theme = None

    def load_theme(self, theme_name: str):
        """加载主题"""
        theme_path = self.theme_dir / theme_name

        # 1. 解析颜色
        css_file = self.theme_dir / "base.css"
        theme_css = theme_path / "style.css"

        colors = self.css_parser.parse_file(str(css_file))
        if theme_css.exists():
            # 合并主题特定颜色覆盖
            theme_colors = self.css_parser.parse_file(str(theme_css))
            colors.update(theme_colors)

        # 2. 扫描图标
        icons_dir = theme_path / "images"
        icons = self._scan_icons(icons_dir)

        # 3. 创建主题对象
        self.current_theme = {
            'name': theme_name,
            'colors': colors,
            'icons': icons,
            'icons_dir': icons_dir
        }

        return self.current_theme

    def _scan_icons(self, icons_dir: Path) -> Dict[str, Path]:
        """扫描图标目录"""
        icons = {}
        for icon_file in icons_dir.glob("*.svg"):
            icon_name = icon_file.stem
            icons[icon_name] = icon_file
        return icons
```

### 2.2 后端：创建 QML 提供者 / Backend: Create QML Provider

创建 `backend/theme_provider.py`:

```python
from PySide6.QtCore import QObject, Property, Signal, Slot

class ThemeProvider(QObject):
    """QML 主题提供者"""

    themeChanged = Signal()

    def __init__(self, theme_manager):
        super().__init__()
        self.theme_manager = theme_manager
        self.theme = theme_manager.current_theme

    # 颜色属性 / Color properties
    @Property(str, notify=themeChanged)
    def backgroundColor(self) -> str:
        return self.theme['colors'].get('bg', '#13181C')

    @Property(str, notify=themeChanged)
    def textColor(self) -> str:
        return self.theme['colors'].get('text', '#FFFFFF')

    @Property(str, notify=themeChanged)
    def color1(self) -> str:
        return self.theme['colors'].get('color1', '#ED6500')

    @Property(str, notify=themeChanged)
    def warningColor(self) -> str:
        return self.theme['colors'].get('warning', '#F9A825')

    # 图标路径方法 / Icon path method
    @Slot(str, result=str)
    def getIconPath(self, icon_name: str) -> str:
        """获取图标路径"""
        icon_path = self.theme['icons'].get(icon_name)
        if icon_path:
            return f"file://{icon_path.as_posix()}"
        return ""  # 或返回占位符 / or return placeholder
```

### 2.3 主程序：注册 QML 上下文 / Main: Register QML Context

编辑 `main.py`:

```python
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

from backend.theme_manager import ThemeManager
from backend.theme_provider import ThemeProvider

def main():
    app = QGuiApplication(sys.argv)

    # 1. 创建主题管理器 / Create theme manager
    theme_manager = ThemeManager(theme_dir="KlipperScreen/styles")
    theme_manager.load_theme("material-dark")

    # 2. 创建 QML 提供者 / Create QML provider
    theme_provider = ThemeProvider(theme_manager)

    # 3. 创建 QML 引擎 / Create QML engine
    engine = QQmlApplicationEngine()

    # 4. 注册上下文属性 / Register context property
    engine.rootContext().setContextProperty("ThemeProvider", theme_provider)

    # 5. 加载 QML / Load QML
    engine.load(QUrl.fromLocalFile("qml/Main.qml"))

    return app.exec()

if __name__ == "__main__":
    sys.exit(main())
```

### 2.4 QML：使用 ThemeProvider / QML: Use ThemeProvider

创建 `qml/Main.qml`:

```qml
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    title: "QtKs - KlipperScreen UI"

    // 使用主题背景色 / Use theme background color
    color: ThemeProvider.backgroundColor

    Column {
        anchors.centerIn: parent
        spacing: 20

        // 显示主题化图标 / Display themed icon
        Image {
            source: ThemeProvider.getIconPath("home")
            sourceSize: Qt.size(48, 48)
            cache: true
            asynchronous: true
        }

        Text {
            // 使用主题文字色 / Use theme text color
            color: ThemeProvider.textColor
            text: "QtKs - KlipperScreen UI"
            font.pixelSize: 24
        }

        Rectangle {
            width: 200
            height: 50
            // 使用主题色 / Use theme color
            color: ThemeProvider.color1

            Text {
                anchors.centerIn: parent
                color: "white"
                text: "主题色按钮 / Theme Button"
            }
        }
    }
}
```

### 2.5 运行应用 / Run Application

```bash
# 开发模式运行 / Run in development mode
python3 main.py

# 你应该看到 / You should see:
# - 带有 KlipperScreen 颜色的窗口 / Window with KlipperScreen colors
# - home 图标 / home icon
# - 主题化的文本和按钮 / Themed text and buttons
```

---

## 步骤 3: 添加自定义图标 / Step 3: Adding Custom Icons

### 3.1 放置自定义 SVG 到主题目录 / Place Custom SVG in Theme Directory

```bash
# 创建自定义图标目录 / Create custom icons directory
mkdir -p assets/custom_icons

# 复制自定义图标 / Copy custom icon
cp my_custom_icon.svg assets/custom_icons/

# 或直接放入主题目录 / Or place directly in theme directory
cp my_custom_icon.svg KlipperScreen/styles/material-dark/images/
```

### 3.2 在配置中引用自定义图标 / Reference Custom Icon in Config

编辑 `config.json`:

```json
{
  "theme": {
    "selected_theme": "material-dark",
    "theme_dir": "KlipperScreen/styles",
    "custom_icons_enabled": true,
    "custom_icons_dir": "assets/custom_icons"
  }
}
```

### 3.3 QML 中使用自定义图标 / Use Custom Icon in QML

```qml
Image {
    source: ThemeProvider.getIconPath("my_custom_icon")
    sourceSize: Qt.size(48, 48)
}
```

---

## 步骤 4: 测试主题切换 / Step 4: Testing Theme Switching

### 4.1 修改配置文件 / Modify Config File

```json
{
  "theme": {
    "selected_theme": "material-light",  // 改为浅色主题 / Change to light theme
    "theme_dir": "KlipperScreen/styles"
  }
}
```

### 4.2 重启应用查看新主题 / Restart App to See New Theme

```bash
python3 main.py

# 你应该看到 / You should see:
# - 浅色背景 / Light background
# - 深色文字 / Dark text
# - material-light 主题的图标 / material-light theme icons
```

### 4.3 运行时主题切换（可选）/ Runtime Theme Switching (Optional)

```qml
// 添加主题切换按钮 / Add theme switch button
Button {
    text: "切换主题 / Switch Theme"
    onClicked: {
        // 调用后端切换主题 / Call backend to switch theme
        ThemeProvider.setTheme(
            ThemeProvider.currentTheme === "material-dark"
                ? "material-light"
                : "material-dark"
        )
    }
}

// 监听主题变化 / Listen for theme changes
Connections {
    target: ThemeProvider
    function onThemeChanged() {
        console.log("主题已切换 / Theme switched")
    }
}
```

---

## 常见问题 / Troubleshooting

### 问题 1: 图标不显示 / Issue 1: Icons Not Displaying

**症状 / Symptom:**
```
Image 组件显示空白 / Image component shows blank
```

**解决方案 / Solution:**
```bash
# 1. 检查图标文件存在 / Check icon file exists
ls KlipperScreen/styles/material-dark/images/home.svg

# 2. 检查路径格式 / Check path format
# QML 中打印路径 / Print path in QML
console.log(ThemeProvider.getIconPath("home"))
# 应该输出 / Should output: file:///home/tope/.../home.svg

# 3. 验证文件权限 / Verify file permissions
chmod +r KlipperScreen/styles/material-dark/images/*.svg
```

### 问题 2: 颜色未应用 / Issue 2: Colors Not Applied

**症状 / Symptom:**
```
界面使用默认颜色而非主题颜色 / UI uses default colors instead of theme colors
```

**解决方案 / Solution:**
```python
# 1. 检查 CSS 解析 / Check CSS parsing
from backend.css_parser import GTKCSSColorResolver

parser = GTKCSSColorResolver()
colors = parser.parse_file("KlipperScreen/styles/base.css")
print(colors)  # 应该显示所有颜色 / Should show all colors

# 2. 验证 QML 属性 / Verify QML property
# QML 中 / In QML:
console.log(ThemeProvider.backgroundColor)  # 应输出 "#13181C"
```

### 问题 3: SVG 渲染问题 / Issue 3: SVG Rendering Issues

**症状 / Symptom:**
```
某些 SVG 图标显示不正确 / Some SVG icons display incorrectly
```

**解决方案 / Solution:**
```bash
# 1. 检查 SVG 兼容性 / Check SVG compatibility
# 参考 research.md 中的兼容性分析 / Refer to compatibility analysis in research.md

# 2. 对于 clipPath 问题（如 spoolman.svg）/ For clipPath issues (e.g., spoolman.svg)
inkscape --actions="select-all;object-to-path;export-plain-svg" \
         spoolman.svg -o spoolman_converted.svg

# 3. 对于 CSS 变量问题（如 spool.svg）/ For CSS variable issues (e.g., spool.svg)
# 使用 Python 预处理 / Use Python preprocessing
python scripts/process_svg_vars.py spool.svg
```

---

## 性能优化建议 / Performance Optimization Tips

### 1. 调整 QPixmapCache 限制 / Adjust QPixmapCache Limit

```python
# main.py
from PySide6.QtGui import QPixmapCache

# 为 100+ 图标预留 20MB / Reserve 20MB for 100+ icons
QPixmapCache.setCacheLimit(20 * 1024)  # 20MB in KB
```

### 2. 预加载关键图标 / Preload Critical Icons

```qml
// Main.qml
Component.onCompleted: {
    // 预加载启动所需的关键图标 / Preload critical icons for startup
    var criticalIcons = [
        "home", "back", "files", "control", "settings", "dashboard"
    ]

    for (var i = 0; i < criticalIcons.length; i++) {
        preloadIcon(criticalIcons[i])
    }
}

function preloadIcon(iconName) {
    var tempImg = Qt.createQmlObject(
        'import QtQuick; Image { source: "' +
        ThemeProvider.getIconPath(iconName) +
        '"; cache: true; asynchronous: true }',
        parent, "preloader"
    )
    tempImg.statusChanged.connect(function() {
        if (tempImg.status === Image.Ready) {
            tempImg.destroy(100)  // 销毁对象，缓存保留
        }
    })
}
```

### 3. 使用 sourceSize 限制渲染 / Use sourceSize to Limit Rendering

```qml
Image {
    source: ThemeProvider.getIconPath("home")

    // ✓ 推荐：限制渲染尺寸 / Recommended: Limit render size
    sourceSize.width: 48
    sourceSize.height: 48

    // ✗ 避免：使用原始 SVG 尺寸 / Avoid: Use original SVG size
    // (可能导致过度渲染 / May cause over-rendering)
}
```

---

## 下一步 / Next Steps

1. **实现完整的主题管理器** / Implement Full Theme Manager
   - 参考 `data-model.md` 中的数据模型 / Refer to data model in data-model.md
   - 参考 `contracts/theme-api.yaml` 中的 API 契约 / Refer to API contract in contracts/theme-api.yaml

2. **添加所有 5 个主题** / Add All 5 Themes
   ```python
   themes = ["material-dark", "material-darker", "material-light", "colorized", "z-bolt"]
   ```

3. **实现图标缓存** / Implement Icon Caching
   - 参考 `research.md` 中的缓存策略 / Refer to caching strategy in research.md

4. **集成到现有 UI** / Integrate into Existing UI
   - 更新 `qml/Style.qml` 使用 ThemeProvider / Update qml/Style.qml to use ThemeProvider
   - 更新所有图标路径 / Update all icon paths

---

## 参考资料 / References

- [Qt SVG 模块文档 / Qt SVG Module Documentation](https://doc.qt.io/qt-6/qtsvg-index.html)
- [PySide6 QML 集成 / PySide6 QML Integration](https://doc.qt.io/qtforpython-6/tutorials/qmlintegration/qmlintegration.html)
- [KlipperScreen 源代码 / KlipperScreen Source](https://github.com/KlipperScreen/KlipperScreen)
- 项目文档 / Project Documentation:
  - `specs/002-ui-assets/spec.md` - 功能规范 / Feature Specification
  - `specs/002-ui-assets/research.md` - 研究报告 / Research Report
  - `specs/002-ui-assets/data-model.md` - 数据模型 / Data Model
  - `specs/002-ui-assets/contracts/theme-api.yaml` - API 契约 / API Contract

---

**完成时间 / Completion Time**: 如果遇到问题，请参考 Troubleshooting 部分或查阅详细文档。
If you encounter issues, refer to the Troubleshooting section or consult detailed documentation.

**支持 / Support**: 在项目 Issues 中提问或查看现有讨论。
Ask questions in project Issues or review existing discussions.
