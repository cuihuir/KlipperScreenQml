# 任务列表：KlipperScreen UI 素材集成 / Tasks: KlipperScreen UI Assets Integration

**输入 / Input**: 设计文档来自 `/specs/002-ui-assets/`
**前置条件 / Prerequisites**: plan.md (必需), spec.md (必需), research.md, data-model.md, contracts/theme-api.yaml

**测试 / Tests**: 本功能规范未明确要求测试优先开发，测试任务可选。
This feature spec doesn't explicitly request test-first development; test tasks are optional.

**组织方式 / Organization**: 任务按用户故事分组，支持每个故事的独立实现和测试。
Tasks grouped by user story to enable independent implementation and testing.

## 格式说明 / Format: `[ID] [P?] [Story] Description`

- **[P]**: 可并行运行（不同文件，无依赖）/ Can run in parallel (different files, no dependencies)
- **[Story]**: 任务属于哪个用户故事（如 US1, US2）/ Which user story this task belongs to
- 描述中包含精确文件路径 / Include exact file paths in descriptions

## 路径约定 / Path Conventions

基于 plan.md 的项目结构（单一项目）/ Based on plan.md structure (single project):
- **后端 / Backend**: `backend/` (Python modules)
- **前端 / Frontend**: `qml/` (QML components)
- **素材源 / Asset source**: `KlipperScreen/styles/` (只读 / read-only)
- **测试 / Tests**: `tests/` (Python unit tests, QML tests)

---

## Phase 1: 设置阶段 / Setup (Shared Infrastructure)

**目的 / Purpose**: 项目初始化和基础结构设置
Project initialization and basic structure setup

- [ ] T001 验证 KlipperScreen 目录结构存在于 `KlipperScreen/styles/`
- [ ] T002 创建 Python 后端模块目录结构：`backend/theme_manager.py`, `backend/icon_loader.py`, `backend/css_parser.py`, `backend/asset_cache.py`
- [ ] T003 [P] 创建 QML 主题组件目录结构：`qml/themes/`, `qml/components/`
- [ ] T004 [P] 配置 Python 开发环境：验证 PySide6 >= 6.7.0, Qt SVG 模块已安装
- [ ] T005 [P] 在 `config.json` 中添加主题配置选项（selected_theme, theme_dir, fallback_theme）

---

## Phase 2: 基础阶段 / Foundational (Blocking Prerequisites)

**目的 / Purpose**: 核心基础设施，必须在任何用户故事实现前完成
Core infrastructure that MUST be complete before ANY user story implementation

**⚠️ 关键 / CRITICAL**: 所有用户故事工作必须等此阶段完成后才能开始
No user story work can begin until this phase is complete

### 数据模型 / Data Models

- [ ] T006 [P] 创建 `ColorPalette` 数据类在 `backend/models/color_palette.py`（包含 color1-4, bg, active, warning, error, text 等字段和验证）
- [ ] T007 [P] 创建 `IconAsset` 数据类在 `backend/models/icon_asset.py`（name, file_path, format, svg_data, cached_time）
- [ ] T008 [P] 创建 `Theme` 数据类在 `backend/models/theme.py`（name, base_dir, colors, icons_dir, icons 字典）
- [ ] T009 [P] 创建 `ThemeConfiguration` 数据类在 `backend/models/theme_config.py`（selected_theme, theme_dir, fallback_theme, custom_icons_enabled）

### CSS 解析器 / CSS Parser

- [ ] T010 实现 GTK CSS 解析器在 `backend/css_parser.py`：
  - `parse_file(css_path)` - 使用正则表达式提取 @define-color 定义
  - `_resolve_references(colors)` - 递归解析颜色变量引用（@bg, @text）
  - `to_qml_format(colors)` - 转换为 QML Singleton 格式
  - `_to_camel_case(name)` - 转换命名为驼峰格式（text-inv → textInv）
  - `_css_to_qml_color(css_color)` - CSS 颜色转 QML 十六进制格式

### 素材缓存 / Asset Cache

- [ ] T011 实现资产缓存管理器在 `backend/asset_cache.py`：
  - 初始化 `max_cache_size = 20MB`
  - `get(icon_name)` - 获取图标并更新访问时间
  - `set(icon_name, icon)` - 添加图标，必要时 LRU 淘汰
  - `evict_lru()` - 淘汰最久未使用的图标
  - `clear()` - 清空所有缓存
  - `cache_usage_percent` 属性

**检查点 / Checkpoint**: 基础架构就绪 - 用户故事实现现在可以并行开始
Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - 视觉一致性 / Visual Consistency with KlipperScreen (Priority: P1) 🎯 MVP

**目标 / Goal**: 实现与 KlipperScreen 视觉上一致的界面，使用相同的图标、颜色和视觉样式
Achieve visual consistency with KlipperScreen using same icons, colors, and visual styling

**独立测试 / Independent Test**: 并排放置 QtKs 和 KlipperScreen 截图，验证图标、颜色、按钮样式和字体在可接受容差内匹配（考虑 GTK vs QML 渲染差异）
Side-by-side screenshots of QtKs and KlipperScreen verify icons, colors, button styles, and typography match within acceptable tolerance

### 实现任务 / Implementation Tasks

#### 图标加载器 / Icon Loader

- [ ] T012 [P] [US1] 实现图标加载器在 `backend/icon_loader.py`：
  - 依赖 `AssetCache`
  - `loadIcon(icon_name, theme)` - 加载指定图标，优先使用缓存
  - `preloadIcons(icon_names, theme)` - 预加载图标列表
  - `getIconPath(icon_name, theme, format)` - 返回 file:// 或 qrc:// 格式路径
  - 回退机制：主题图标 → 基础主题 → 占位符图标

#### 主题管理器 / Theme Manager

- [ ] T013 [US1] 实现主题管理器在 `backend/theme_manager.py`：
  - 依赖 `CSSParser`, `IconLoader`, `AssetCache`
  - `loadTheme(theme_name)` - 加载主题（解析 CSS + 扫描图标）
  - `parseThemeColors(css_file_path)` - 解析主题颜色
  - `listAvailableThemes()` - 列出所有可用主题
  - `reloadCurrentTheme()` - 重新加载当前主题
  - 验证主题名称（material-dark, material-darker, material-light, colorized, z-bolt, base）

#### QML 颜色模块 / QML Color Module

- [ ] T014 [P] [US1] 创建 QML 颜色 Singleton 在 `qml/themes/KlipperColors.qml`：
  - `pragma Singleton`
  - readonly property color 定义（color1-4, bg, active, warning, error, text, textInv, lines）
  - 从 `backend/css_parser.py` 自动生成或手动映射

#### QML 主题提供者 / QML Theme Provider

- [ ] T015 [US1] 实现 QML 主题提供者（QObject）在 `backend/theme_provider.py`：
  - 继承 `QObject`
  - Property: `currentTheme`, `backgroundColor`, `textColor`, `color1-4`, `activeColor`, `warningColor`, `errorColor`
  - Signal: `themeChanged()`, `themeLoadError(errorMessage)`
  - Slot: `getIconPath(icon_name)`, `getAvailableThemes()`, `setTheme(theme_name)`
  - 在 `main.py` 中注册为 QML 上下文属性

#### 主应用集成 / Main Application Integration

- [ ] T016 [US1] 在 `main.py` 中集成主题系统：
  - 创建 `ThemeManager` 实例
  - 加载默认主题（material-dark）
  - 创建 `ThemeProvider` 实例
  - 注册 `ThemeProvider` 到 QML 引擎上下文
  - 设置 `QPixmapCache.setCacheLimit(20 * 1024)` (20MB)

#### QML 主题化图标组件 / QML Themed Icon Component

- [ ] T017 [P] [US1] 创建可重用主题化图标组件在 `qml/components/ThemedIcon.qml`：
  - 属性：`iconName`, `iconSize`（默认 48x48）
  - 使用 `ThemeProvider.getIconPath(iconName)`
  - 设置 `cache: true`, `asynchronous: true`, `sourceSize` 限制
  - 错误处理：缺失图标时显示占位符

#### 样式文件更新 / Style File Updates

- [ ] T018 [US1] 更新 `qml/Style.qml` 使用 `ThemeProvider` 颜色：
  - 导入 `KlipperColors` Singleton
  - 替换硬编码颜色为 `ThemeProvider.backgroundColor` 等
  - 保持现有 `baseUnit`, `durationFast` 等非颜色属性

**检查点 / Checkpoint**: 用户故事 1 应该完全功能化且可独立测试 - 界面应显示 KlipperScreen 图标和颜色
User Story 1 should be fully functional and independently testable - interface displays KlipperScreen icons and colors

---

## Phase 4: User Story 2 - 主题支持 / Theme Support (Priority: P1)

**目标 / Goal**: 支持所有 5 个 KlipperScreen 内置主题，允许用户自定义界面外观
Support all 5 KlipperScreen built-in themes for interface customization

**独立测试 / Independent Test**: 在配置文件中配置每个可用主题，重启应用，验证界面匹配 KlipperScreen 该主题的外观
Configure each theme in config file, restart app, verify interface matches KlipperScreen's appearance for that theme

### 实现任务 / Implementation Tasks

- [ ] T019 [P] [US2] 实现主题配置加载在 `backend/config_loader.py`：
  - `load_theme_config(config_path)` - 从 `config.json` 读取主题配置
  - 验证 `selected_theme` 存在于可用主题中
  - 返回 `ThemeConfiguration` 对象

- [ ] T020 [US2] 扩展 `ThemeManager.loadTheme()` 支持所有 5 个主题：
  - 验证主题目录：`KlipperScreen/styles/{material-dark, material-darker, material-light, colorized, z-bolt}`
  - 合并基础 CSS（base.css）和主题特定 CSS（style.css）
  - 处理主题回退：选中主题 → 基础主题

- [ ] T021 [P] [US2] 为每个主题生成 QML 颜色 Singleton（如需要）：
  - `qml/themes/MaterialDark.qml`
  - `qml/themes/MaterialDarker.qml`
  - `qml/themes/MaterialLight.qml`
  - `qml/themes/Colorized.qml`
  - `qml/themes/ZBolt.qml`
  - 或使用单一 `KlipperColors.qml` 动态加载

- [ ] T022 [US2] 实现主题切换逻辑在 `ThemeProvider.setTheme()`：
  - 调用 `ThemeManager.loadTheme(new_theme)`
  - 清空图标缓存（`AssetCache.clear()`）
  - 发出 `themeChanged()` 信号
  - 更新所有颜色属性

- [ ] T023 [P] [US2] 添加主题切换 UI 控件（可选，用于测试）：
  - 在设置页面或开发菜单中添加主题选择器
  - 显示所有可用主题
  - 选择后调用 `ThemeProvider.setTheme()`

- [ ] T024 [US2] 验证主题一致性：
  - 所有 5 个主题的 CSS 解析成功
  - 所有主题的图标路径正确（优先主题图标，回退到基础）
  - 颜色定义完整（color1-4, bg, active, warning, error, text 等）

**检查点 / Checkpoint**: 用户故事 1 和 2 都应独立工作 - 可切换主题并保持视觉一致性
User Stories 1 AND 2 should both work independently - can switch themes and maintain visual consistency

---

## Phase 5: User Story 3 - 图标集完整性 / Icon Set Completeness (Priority: P1)

**目标 / Goal**: 确保所有 UI 元素显示 KlipperScreen 图标库中的正确图标（100+ 图标）
Ensure all UI elements display proper icons from KlipperScreen's icon library (100+ icons)

**独立测试 / Independent Test**: 导航所有面板和功能，创建所用图标清单，验证每个图标从 KlipperScreen 素材正确加载
Navigate all panels and features, create checklist of used icons, verify each loads correctly from KlipperScreen assets

### 实现任务 / Implementation Tasks

- [ ] T025 [P] [US3] 创建图标清单文档 `docs/icon-inventory.md`：
  - 列出所有 QtKs UI 使用的图标名称
  - 映射到 KlipperScreen 图标文件
  - 标识缺失或需要回退的图标

- [ ] T026 [P] [US3] 更新所有现有 QML 组件使用 `ThemedIcon`：
  - `qml/components/FunctionIcon.qml` - 替换硬编码路径为 `ThemedIcon`
  - `qml/components/GlobalNavButtons.qml` - 使用 HOME/RETURN 图标
  - `qml/pages/HomePage.qml` - 使用 Widget 图标
  - `qml/components/NavigationButton.qml` - 使用动态图标路径

- [ ] T027 [P] [US3] 实现特殊图标支持：
  - 编号挤出机图标（extruder-0 到 extruder-9）在 `IconLoader`
  - 床位调平位置图标（bed-level-t-l, bed-level-t-r 等）
  - 电池状态图标（battery-0, battery-25, battery-50, battery-75, battery-100, battery-charging, battery-unknown）
  - WiFi 信号强度图标（wifi_excellent, wifi_good, wifi_fair, wifi_poor）

- [ ] T028 [US3] 实现图标回退机制在 `IconLoader.loadIcon()`：
  - 优先级 1: 当前主题图标目录
  - 优先级 2: 基础主题图标目录
  - 优先级 3: 通用占位符图标（创建 `assets/placeholder.svg`）
  - 记录缺失图标警告到日志

- [ ] T029 [P] [US3] 处理 2 个问题 SVG 文件：
  - `spool.svg` (CSS 变量): 创建 `backend/svg_processor.py` 预处理 CSS 变量
  - `spoolman.svg` (clipPath): 使用 Inkscape 转换或创建简化版

- [ ] T030 [US3] 验证所有图标加载：
  - 编写脚本扫描所有 QML 文件提取图标名称
  - 验证所有引用的图标在 KlipperScreen/styles 中存在
  - 生成缺失图标报告

**检查点 / Checkpoint**: 所有 UI 元素都应显示正确的图标，无缺失或占位符（除非图标真的不存在）
All UI elements should display correct icons without missing or placeholders (unless icon truly doesn't exist)

---

## Phase 6: User Story 4 - 素材加载性能 / Asset Loading and Performance (Priority: P1)

**目标 / Goal**: 快速加载 UI 素材，无延迟或闪烁，保持界面响应性
Load UI assets quickly without delays or flickering, maintaining interface responsiveness

**独立测试 / Independent Test**: 快速导航面板，监控素材加载时间，验证无占位符图标或延迟渲染发生
Navigate rapidly between panels, monitor asset load times, verify no placeholder icons or delayed rendering

### 实现任务 / Implementation Tasks

#### 性能优化 / Performance Optimization

- [ ] T031 [P] [US4] 优化所有 QML Image 组件性能属性：
  - 添加 `cache: true` 到所有图标 Image
  - 添加 `asynchronous: true` 异步加载
  - 设置 `sourceSize: Qt.size(48, 48)` 限制渲染尺寸
  - 添加 `smooth: true` 高质量缩放

- [ ] T032 [P] [US4] 实现核心图标预加载在 `qml/MainWindow.qml`：
  - `Component.onCompleted` 中预加载 6 个关键图标
  - 图标列表：home, back, files, control, settings, dashboard
  - 使用临时 Image 对象加载到缓存后销毁

- [ ] T033 [US4] 实现延迟加载策略：
  - ListView 中设置 `cacheBuffer: Style.baseUnit * 20`
  - 非首屏图标使用 `Loader { active: visible }`
  - 优先级：首屏 → 第二屏 → 其他

#### 性能监控 / Performance Monitoring

- [ ] T034 [P] [US4] 添加性能日志在 `backend/theme_manager.py`：
  - 记录主题加载时间
  - 记录 CSS 解析时间
  - 记录图标扫描时间

- [ ] T035 [P] [US4] 添加性能日志在 `backend/icon_loader.py`：
  - 记录图标首次加载时间
  - 记录缓存命中率
  - 警告超过 50ms 的图标加载

#### 缓存优化 / Cache Optimization

- [ ] T036 [US4] 优化 `AssetCache` 性能：
  - 实现 `_estimate_size()` 准确估算图标内存占用
  - 优化 LRU 淘汰算法（使用 OrderedDict）
  - 添加 `cache_usage_percent` 监控

- [ ] T037 [P] [US4] 验证性能目标达成：
  - 图标首次加载 < 50ms（目标：10-30ms）
  - 图标缓存加载 < 5ms（目标：1-3ms）
  - 主题切换 < 3s（目标：< 2s）
  - 内存使用 < 20MB（目标：~2MB）

**检查点 / Checkpoint**: 界面应快速响应，图标加载即时，无性能问题
Interface should be responsive, icons load instantly, no performance issues

---

## Phase 7: User Story 5 - 自定义图标支持 / Custom Icon Support (Priority: P2)

**目标 / Goal**: 允许用户添加自定义图标用于自定义面板或宏
Allow users to add custom icons for custom panels or macros

**独立测试 / Independent Test**: 添加自定义 SVG 图标到适当目录，配置自定义面板或宏使用它，验证自定义图标正确显示
Add custom SVG icon to directory, configure custom panel/macro to use it, verify custom icon displays correctly

### 实现任务 / Implementation Tasks

- [ ] T038 [P] [US5] 扩展 `ThemeConfiguration` 支持自定义图标：
  - 添加 `custom_icons_enabled: bool` 字段
  - 添加 `custom_icons_dir: Optional[Path]` 字段
  - 在 `config.json` 中添加配置选项

- [ ] T039 [US5] 扩展 `IconLoader.loadIcon()` 支持自定义图标：
  - 新的回退优先级：自定义图标目录 → 主题图标 → 基础图标 → 占位符
  - 验证自定义图标文件可读性
  - 支持 SVG 和 PNG 格式

- [ ] T040 [P] [US5] 创建自定义图标示例：
  - 创建 `assets/custom_icons/` 目录
  - 添加示例自定义图标 SVG
  - 在 `quickstart.md` 中记录用法

- [ ] T041 [P] [US5] 验证自定义图标功能：
  - 测试自定义 SVG 图标加载
  - 测试自定义 PNG 图标加载（可选）
  - 测试缺失自定义图标的回退

**检查点 / Checkpoint**: 用户可以添加和使用自定义图标
Users can add and use custom icons

---

## Phase 8: User Story 6 - 高 DPI 和分辨率缩放 / High-DPI and Resolution Scaling (Priority: P2)

**目标 / Goal**: 图标和素材在不同显示分辨率和 DPI 设置下正确缩放
Icons and assets scale properly on different display resolutions and DPI settings

**独立测试 / Independent Test**: 在不同显示分辨率（800x480, 1024x600, 1920x1080）上运行应用，验证图标保持清晰且尺寸适当
Run application on different resolutions, verify icons remain sharp and properly sized

### 实现任务 / Implementation Tasks

- [ ] T042 [P] [US6] 实现 DPI 感知缩放在 `qml/Style.qml`：
  - 检测显示 DPI（`Screen.pixelDensity`）
  - 调整 `baseUnit` 基于 DPI
  - 计算适当的图标尺寸

- [ ] T043 [P] [US6] 验证 SVG 矢量缩放：
  - 测试 800x480 分辨率（最小）
  - 测试 1024x600 分辨率（中等）
  - 测试 1920x1080 分辨率（高）
  - 验证图标无像素化

- [ ] T044 [US6] 实现触摸目标尺寸验证：
  - 确保最小 48x48px 触摸目标
  - 在 `ThemedIcon` 中添加 `minimumTouchSize` 属性
  - 在小分辨率下自动调整

**检查点 / Checkpoint**: 图标在所有支持的分辨率下都清晰且可触摸
Icons are sharp and touchable on all supported resolutions

---

## Phase 9: 完善与跨功能关注点 / Polish & Cross-Cutting Concerns

**目的 / Purpose**: 最终打磨和跨用户故事的改进
Final polish and improvements across user stories

### 错误处理 / Error Handling

- [ ] T045 [P] 实现全面错误处理在 `backend/theme_manager.py`：
  - 自定义异常：`ThemeNotFoundError`, `ThemeLoadError`
  - 优雅降级：缺失主题 → 回退主题
  - 错误日志记录

- [ ] T046 [P] 实现全面错误处理在 `backend/icon_loader.py`：
  - 自定义异常：`IconNotFoundError`
  - 优雅降级：缺失图标 → 占位符
  - 错误日志记录

### 文档 / Documentation

- [ ] T047 [P] 更新 `quickstart.md` 包含实际实现细节：
  - 添加安装步骤
  - 添加配置示例
  - 添加故障排除部分

- [ ] T048 [P] 创建图标映射文档 `docs/icon-mapping.md`：
  - KlipperScreen 图标名称 → QtKs 使用位置
  - 特殊图标说明（编号挤出机、电池、WiFi）
  - 自定义图标指南

### 配置 / Configuration

- [ ] T049 更新 `config.json` 示例配置：
  - 添加所有主题配置选项
  - 添加注释说明每个选项
  - 提供默认值

### 测试（可选）/ Testing (Optional)

如果需要测试，添加以下任务：
If tests are needed, add the following tasks:

- [ ] T050 [P] 编写单元测试 `tests/test_css_parser.py`：
  - 测试 @define-color 解析
  - 测试颜色引用解析
  - 测试 QML 格式转换

- [ ] T051 [P] 编写单元测试 `tests/test_icon_loader.py`：
  - 测试图标加载
  - 测试缓存机制
  - 测试回退逻辑

- [ ] T052 [P] 编写单元测试 `tests/test_theme_manager.py`：
  - 测试主题加载
  - 测试主题切换
  - 测试错误处理

- [ ] T053 [P] 编写 QML 组件测试 `tests/qml_tests/tst_ThemedIcon.qml`：
  - 测试图标显示
  - 测试缺失图标回退
  - 测试性能

---

## 依赖关系图 / Dependency Graph

```
Phase 1 (Setup)
  ↓
Phase 2 (Foundational) - 必须完成 / Must complete
  ├─ T006-T009: Data Models
  ├─ T010: CSS Parser
  └─ T011: Asset Cache
  ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
并行用户故事实现 / Parallel User Story Implementation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ↓
Phase 3 (US1 - 视觉一致性 / Visual Consistency) 🎯 MVP
  ├─ T012: Icon Loader
  ├─ T013: Theme Manager (depends on T010, T011, T012)
  ├─ T014: QML Colors (可并行 / parallel)
  ├─ T015: Theme Provider (depends on T013)
  ├─ T016: Main Integration (depends on T013, T015)
  ├─ T017: Themed Icon Component (可并行 / parallel)
  └─ T018: Style Updates (depends on T014, T015)
  ↓
Phase 4 (US2 - 主题支持 / Theme Support) - 依赖 US1 / Depends on US1
  ├─ T019-T024: 扩展主题功能 / Extend theme features
  └─ (建立在 Phase 3 基础上 / Built on Phase 3)
  ↓
Phase 5 (US3 - 图标完整性 / Icon Completeness) - 依赖 US1 / Depends on US1
  ├─ T025-T030: 图标清单和更新 / Icon inventory and updates
  └─ (建立在 Phase 3 基础上 / Built on Phase 3)
  ↓
Phase 6 (US4 - 性能 / Performance) - 依赖 US1-3 / Depends on US1-3
  ├─ T031-T037: 性能优化 / Performance optimization
  └─ (优化现有实现 / Optimize existing implementation)
  ↓
Phase 7 (US5 - 自定义图标 / Custom Icons) - 可独立 / Can be independent
  ├─ T038-T041: 自定义图标功能 / Custom icon features
  └─ (扩展 IconLoader / Extend IconLoader)
  ↓
Phase 8 (US6 - 高 DPI / High-DPI) - 可独立 / Can be independent
  ├─ T042-T044: DPI 缩放 / DPI scaling
  └─ (扩展 ThemedIcon / Extend ThemedIcon)
  ↓
Phase 9 (完善 / Polish)
  └─ T045-T053: 错误处理、文档、测试 / Error handling, docs, tests
```

---

## 并行执行示例 / Parallel Execution Examples

### Phase 2 - 基础阶段 / Foundational Phase
**可并行运行 / Can run in parallel**:
- T006, T007, T008, T009 (不同数据模型文件 / Different data model files)

### Phase 3 - User Story 1
**可并行运行 / Can run in parallel**:
- T012 (IconLoader) 和 T014 (QML Colors) - 不同文件
- T017 (ThemedIcon Component) - 不依赖其他任务

**必须顺序 / Must be sequential**:
- T013 必须在 T012 后（IconLoader 依赖）
- T015 必须在 T013 后（ThemeProvider 依赖 ThemeManager）
- T016 必须在 T013, T015 后（Main 集成两者）

### Phase 4-8 - 其他用户故事
大部分任务可以并行，因为它们操作不同的文件或组件。
Most tasks can be parallel as they operate on different files or components.

---

## 实施策略 / Implementation Strategy

### MVP 范围 / MVP Scope (推荐 / Recommended)
**仅实施 User Story 1 (Phase 1-3)**:
- ✅ 基础设施（Phase 1-2）
- ✅ 视觉一致性（Phase 3）
- ✅ 可交付：界面显示 KlipperScreen 图标和颜色

### 增量交付 / Incremental Delivery
1. **Sprint 1**: Phase 1-3 (US1 - 视觉一致性) → MVP
2. **Sprint 2**: Phase 4 (US2 - 主题支持)
3. **Sprint 3**: Phase 5-6 (US3 - 图标完整性, US4 - 性能)
4. **Sprint 4**: Phase 7-8 (US5 - 自定义图标, US6 - 高 DPI)
5. **Sprint 5**: Phase 9 (完善)

---

## 任务统计 / Task Statistics

**总任务数 / Total Tasks**: 53
**按优先级 / By Priority**:
- P1 任务 / P1 Tasks: 44 (Phase 1-6)
- P2 任务 / P2 Tasks: 9 (Phase 7-9)

**按阶段 / By Phase**:
- Phase 1 (Setup): 5 tasks
- Phase 2 (Foundational): 6 tasks
- Phase 3 (US1 - P1): 7 tasks
- Phase 4 (US2 - P1): 6 tasks
- Phase 5 (US3 - P1): 6 tasks
- Phase 6 (US4 - P1): 7 tasks
- Phase 7 (US5 - P2): 4 tasks
- Phase 8 (US6 - P2): 3 tasks
- Phase 9 (Polish): 9 tasks

**并行机会 / Parallel Opportunities**: 23 tasks 标记为 [P]

**独立测试标准 / Independent Test Criteria**:
- ✅ 每个用户故事都有明确的独立测试方法
- ✅ Phase 3 后可交付 MVP
- ✅ 每个阶段都有检查点

---

## 格式验证 / Format Validation

✅ **所有任务遵循清单格式 / All tasks follow checklist format**:
- [x] 所有任务以 `- [ ]` 开头
- [x] 所有任务有唯一 ID (T001-T053)
- [x] 用户故事阶段任务有 [US1]-[US6] 标签
- [x] 可并行任务有 [P] 标记
- [x] 任务描述包含文件路径

✅ **用户故事组织 / User Story Organization**:
- [x] 每个用户故事独立可测试
- [x] 明确的依赖关系
- [x] MVP 范围定义清晰（User Story 1）

---

**任务列表生成完成 / Task List Generation Complete**
**准备实施 / Ready for Implementation**: 使用 `/speckit.implement` 开始执行任务
Use `/speckit.implement` to start executing tasks
