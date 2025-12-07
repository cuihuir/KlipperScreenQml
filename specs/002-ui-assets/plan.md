# 实现计划：KlipperScreen UI 素材集成 / Implementation Plan: KlipperScreen UI Assets Integration

**分支 / Branch**: `002-ui-assets` | **日期 / Date**: 2025-12-07 | **规范 / Spec**: [spec.md](spec.md)
**输入 / Input**: 功能规范来自 `/specs/002-ui-assets/spec.md`

**注意 / Note**: 本模板由 `/speckit.plan` 命令填充。执行工作流程请参见 `.specify/templates/commands/plan.md`。

## 概要 / Summary

本功能实现直接使用 KlipperScreen 的 UI 素材（图标、主题、颜色）到 QtKs 中，确保视觉一致性和主题支持与原始 KlipperScreen 界面完全相同。核心技术方法包括：
1. 从 KlipperScreen/styles 目录加载 SVG 图标库（100+ 图标）
2. 解析 KlipperScreen CSS 文件提取颜色定义并转换为 QML 格式
3. 支持所有 5 个 KlipperScreen 主题（material-dark, material-darker, material-light, colorized, z-bolt）
4. 实现图标缓存和延迟加载以优化性能
5. 提供自定义图标支持和错误处理机制

This feature implements direct use of KlipperScreen's UI assets (icons, themes, colors) in QtKs, ensuring visual consistency and theme support identical to the original KlipperScreen interface. Core technical approach includes:
1. Loading SVG icon library (100+ icons) from KlipperScreen/styles directory
2. Parsing KlipperScreen CSS files to extract color definitions and convert to QML format
3. Supporting all 5 KlipperScreen themes
4. Implementing icon caching and lazy loading for performance optimization
5. Providing custom icon support and error handling mechanisms

## 技术上下文 / Technical Context

**语言/版本 / Language/Version**: Python 3.8+ (后端 / backend), QML Qt 6.x (前端 / frontend)
**主要依赖 / Primary Dependencies**:
- PySide6 (Qt for Python bindings)
- Qt SVG module (QML SVG 渲染 / SVG rendering)
- Qt Quick (QML UI framework)
- Python configparser/json (配置解析 / config parsing)

**存储 / Storage**:
- 文件系统只读访问 / File system read-only access: KlipperScreen/styles/**
- 内存缓存 / In-memory cache for loaded icons and theme data

**测试 / Testing**: pytest (Python 单元测试 / unit tests), QML test framework (UI 测试 / UI tests)

**目标平台 / Target Platform**:
- Linux ARM (Orange Pi, Raspberry Pi)
- Linux x86_64 (开发环境 / development)
- 显示分辨率 / Display resolutions: 800x480 至 / to 1920x1080

**项目类型 / Project Type**: Single project (QML frontend + Python backend in unified structure)

**性能目标 / Performance Goals**:
- 图标加载 / Icon loading: <50ms 首次加载 / first load, <5ms 缓存加载 / cached
- 主题切换 / Theme switching: <3s 从启动到主菜单 / from launch to main menu
- 内存使用 / Memory usage: <20MB 完整图标库缓存 / for complete icon library cache
- 渲染性能 / Rendering: 30fps 最小帧率 / minimum framerate

**约束 / Constraints**:
- 必须与现有 KlipperScreen 目录结构兼容 / Must be compatible with existing KlipperScreen directory structure
- SVG 渲染必须支持 Qt SVG 模块功能 / SVG rendering must support Qt SVG module capabilities
- 不修改 KlipperScreen 原始素材文件 / Do not modify KlipperScreen original asset files
- 主题切换需要应用重启（匹配 KlipperScreen 行为）/ Theme switching requires app restart (matching KlipperScreen behavior)

**规模/范围 / Scale/Scope**:
- 100+ SVG 图标文件 / SVG icon files
- 5 个主题 / themes with complete asset sets
- 10-15 颜色定义每主题 / color definitions per theme
- 支持自定义图标扩展 / Support custom icon extensions

## 宪章检查 / Constitution Check

*门禁：Phase 0 研究前必须通过。Phase 1 设计后重新检查。*
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### 核心原则验证 / Core Principles Validation

✅ **I. 双语文档规范 / Bilingual Documentation Standard**
- 本计划文档使用中英双语 / This plan uses bilingual format
- 用户面向内容（概要、任务）使用中文 / User-facing content in Chinese
- 技术细节提供英文版本保持精确性 / Technical details in English for precision

✅ **II. QML/Python 架构 / QML/Python Architecture**
- QML 用于 UI 渲染（图标显示、主题应用）/ QML for UI rendering
- Python 用于素材加载、CSS 解析、缓存管理 / Python for asset loading, CSS parsing, cache management
- 通过 QML 属性和信号槽通信 / Communication via QML properties and signals

✅ **III. 渐进式开发 / Progressive Development**
- P1 优先级：视觉一致性、主题支持、图标集完整性、素材加载性能 / P1: Visual consistency, theme support, icon completeness, asset performance
- P2 优先级：自定义图标支持、高 DPI 缩放 / P2: Custom icons, high-DPI scaling
- 每个优先级独立可测试 / Each priority independently testable

✅ **IV. QML 导入规范 / QML Import Standards**
- 所有 QML 图标资源使用绝对路径或 QML 资源系统 / All QML icon resources use absolute paths or QML resource system
- 禁止相对路径导入 / Relative path imports prohibited
- 配置 QML 模块路径支持清晰命名空间 / Configure QML module paths for clear namespacing

### 开发流程验证 / Development Workflow Validation

✅ **功能开发流程 / Feature Development Process**
1. ✅ 已创建功能规范（中文）/ Feature spec created (Chinese): spec.md
2. 🔄 正在生成实现计划（中英双语）/ Generating implementation plan (bilingual): plan.md
3. ⏳ 待创建任务列表 / Task list pending: tasks.md (via `/speckit.tasks`)
4. ⏳ 待执行实现 / Implementation pending: (via `/speckit.implement`)
5. ✅ 提交前确认约定 / Pre-commit confirmation agreement: 遵守 CLAUDE.md 规定 / Following CLAUDE.md requirements

### 技术约束验证 / Technical Constraints Validation

✅ **UI 框架 / UI Framework**
- 使用 PySide6 + QML / Using PySide6 + QML ✓
- 视觉风格遵循 KlipperScreen（本功能的核心目标）/ Visual style follows KlipperScreen (core goal)
- 触摸优先设计（最小 48x48px 触摸目标）/ Touch-first design (minimum 48x48px targets)

✅ **后端架构 / Backend Architecture**
- Python 3.8+ ✓
- 素材加载不涉及 Moonraker API（纯本地文件系统）/ Asset loading doesn't involve Moonraker (local filesystem only)

### 门禁结果 / Gate Result

**✅ 通过 / PASS** - 无违规，可以继续 Phase 0 研究 / No violations, proceed to Phase 0 research

## 项目结构 / Project Structure

### 文档（本功能）/ Documentation (this feature)

```text
specs/002-ui-assets/
├── plan.md              # 本文件 / This file (/speckit.plan 输出 / output)
├── research.md          # Phase 0 输出 / output (/speckit.plan)
├── data-model.md        # Phase 1 输出 / output (/speckit.plan)
├── quickstart.md        # Phase 1 输出 / output (/speckit.plan)
├── contracts/           # Phase 1 输出 / output (/speckit.plan)
│   └── theme-api.yaml   # 主题加载 API 契约 / Theme loading API contract
└── tasks.md             # Phase 2 输出 / output (/speckit.tasks - 未由 /speckit.plan 创建 / NOT created by /speckit.plan)
```

### 源代码（仓库根目录）/ Source Code (repository root)

```text
backend/
├── theme_manager.py         # 主题管理器：加载主题、解析 CSS、管理颜色 / Theme manager
├── icon_loader.py           # 图标加载器：SVG 加载、缓存、验证 / Icon loader
├── css_parser.py            # CSS 解析器：提取颜色定义 / CSS parser
└── asset_cache.py           # 素材缓存：内存缓存管理 / Asset cache manager

qml/
├── themes/
│   ├── ThemeProvider.qml    # 主题提供者：暴露主题数据给 QML / Theme provider
│   ├── ColorPalette.qml     # 颜色调色板：主题颜色定义 / Color palette
│   └── IconLibrary.qml      # 图标库：图标访问接口 / Icon library interface
└── components/
    └── ThemedIcon.qml       # 主题化图标组件：可重用图标组件 / Themed icon component

KlipperScreen/               # KlipperScreen 源代码（只读引用）/ KlipperScreen source (read-only)
└── styles/                  # 素材源目录 / Asset source directory
    ├── base.css             # 基础颜色定义 / Base color definitions
    ├── material-dark/       # Material Dark 主题 / theme
    │   ├── style.css        # 主题颜色覆盖 / Theme color overrides
    │   ├── style.conf       # 主题配置 / Theme config
    │   └── images/          # 主题图标 / Theme icons (100+ SVG files)
    ├── material-darker/
    ├── material-light/
    ├── colorized/
    └── z-bolt/

tests/
├── test_theme_manager.py    # 主题管理器测试 / Theme manager tests
├── test_icon_loader.py      # 图标加载器测试 / Icon loader tests
├── test_css_parser.py       # CSS 解析器测试 / CSS parser tests
└── qml_tests/               # QML 组件测试 / QML component tests
    └── tst_ThemedIcon.qml
```

**结构决策 / Structure Decision**:
采用单一项目结构（Single project structure），因为这是一个统一的桌面应用程序，QML 前端和 Python 后端紧密集成。素材管理逻辑主要在 backend/ 中实现（Python），QML 组件在 qml/ 中提供 UI 绑定。KlipperScreen/ 目录作为只读素材源，不修改其内容。

Using single project structure because this is a unified desktop application with tightly integrated QML frontend and Python backend. Asset management logic implemented primarily in backend/ (Python), with QML components in qml/ providing UI bindings. KlipperScreen/ directory serves as read-only asset source without modifications.

## 复杂度跟踪 / Complexity Tracking

> **仅在宪章检查有必须证明的违规时填写 / Fill ONLY if Constitution Check has violations that must be justified**

本功能无宪章违规，此表留空。
This feature has no constitution violations, table left empty.

## Phase 0: 大纲与研究 / Outline & Research

### 需要研究的未知项 / Research Unknowns

以下技术细节需要研究以确定最佳实践：
Following technical details require research to determine best practices:

1. **QML SVG 渲染能力 / QML SVG Rendering Capabilities**
   - Qt SVG 模块支持哪些 SVG 1.1 特性？/ Which SVG 1.1 features are supported by Qt SVG module?
   - KlipperScreen 的 SVG 图标使用了哪些特性？/ What SVG features do KlipperScreen icons use?
   - 是否需要 SVG 转换或清理？/ Is SVG conversion or sanitization needed?

2. **CSS 到 QML 颜色转换 / CSS to QML Color Conversion**
   - 如何解析 GTK CSS @define-color 语法？/ How to parse GTK CSS @define-color syntax?
   - QML 颜色格式最佳实践（字符串 vs Color 对象）/ QML color format best practices (string vs Color object)?
   - 如何处理 CSS 颜色变量引用（@bg, @text）？/ How to handle CSS color variable references?

3. **QML 资源系统 vs 文件系统路径 / QML Resource System vs Filesystem Paths**
   - 应该使用 Qt 资源系统（qrc）还是直接文件路径？/ Should use Qt resource system (qrc) or direct file paths?
   - 开发 vs 生产环境的素材路径管理 / Asset path management in dev vs production
   - 性能影响：qrc vs file:// URLs / Performance implications: qrc vs file:// URLs

4. **图标缓存策略 / Icon Caching Strategy**
   - QML Image 组件的内置缓存行为 / QML Image component's built-in caching behavior
   - Python 端是否需要额外缓存？/ Is additional Python-side caching needed?
   - 内存 vs 磁盘缓存权衡 / Memory vs disk cache tradeoffs

5. **主题热重载 / Theme Hot Reloading**
   - 是否可能实现无需重启的主题切换？/ Is theme switching without restart possible?
   - 如果支持，需要哪些 QML 绑定和信号？/ If supported, what QML bindings and signals are needed?
   - 规范要求重启，但技术可行性如何？/ Spec requires restart, but what is technical feasibility?

6. **错误处理和回退策略 / Error Handling and Fallback Strategy**
   - 缺失图标的默认占位符如何实现？/ How to implement default placeholder for missing icons?
   - SVG 解析失败时的降级方案 / Degradation plan when SVG parsing fails
   - 主题加载失败时回退到基础主题的机制 / Mechanism to fall back to base theme on load failure

### 研究任务派遣 / Research Task Dispatch

将派遣以下研究代理任务（Phase 0 执行）：
Will dispatch following research agent tasks (executed in Phase 0):

1. **研究 Qt SVG 模块和 KlipperScreen SVG 兼容性**
   Research Qt SVG module and KlipperScreen SVG compatibility
   - 验证 Qt 6.x SVG 渲染器支持的特性
   - 分析 KlipperScreen 图标文件使用的 SVG 元素
   - 确定是否需要预处理或转换

2. **研究 GTK CSS 解析和 QML 颜色映射最佳实践**
   Research GTK CSS parsing and QML color mapping best practices
   - 找到解析 @define-color 语法的 Python 库或方法
   - 确定 QML 中定义动态颜色调色板的模式
   - 研究颜色变量解析和替换算法

3. **研究 QML 资源管理和素材路径策略**
   Research QML resource management and asset path strategies
   - 比较 qrc 资源系统 vs 直接文件路径的优缺点
   - 确定开发和生产环境的路径配置方案
   - 评估性能和可维护性影响

4. **研究 QML 图标缓存和性能优化模式**
   Research QML icon caching and performance optimization patterns
   - 分析 QML Image 组件的缓存行为
   - 确定是否需要 Python 端缓存层
   - 研究延迟加载和预加载策略

**输出 / Output**: research.md 包含所有决策、理由和备选方案
research.md with all decisions, rationales, and alternatives

## Phase 1: 设计与契约 / Design & Contracts

**前提条件 / Prerequisites**: research.md 完成 / complete

### 数据模型 / Data Model

将从功能规范中提取以下实体并详细定义于 data-model.md：
Will extract following entities from feature spec and detail in data-model.md:

1. **Theme / 主题**
   - 字段 / Fields: name, base_dir, colors (ColorPalette), icons (IconAsset[])
   - 关系 / Relationships: has-many IconAsset, has-one ColorPalette
   - 验证 / Validation: name must match available theme directories

2. **ColorPalette / 颜色调色板**
   - 字段 / Fields: primary_colors (color1-4), semantic_colors (bg, active, warning, error), text_colors (text, text_inv, lines)
   - 来源 / Source: parsed from CSS @define-color definitions
   - 验证 / Validation: all color values must be valid hex/rgb strings

3. **IconAsset / 图标素材**
   - 字段 / Fields: name, file_path, svg_data (cached), format (svg/png), size_hint
   - 缓存状态 / Cache state: loaded, cached_time
   - 验证 / Validation: file must exist and be readable

4. **AssetCache / 素材缓存**
   - 字段 / Fields: cached_icons (dict), cache_size_bytes, max_cache_size
   - 操作 / Operations: get(icon_name), set(icon_name, data), evict_lru()
   - 约束 / Constraints: cache_size < max_cache_size (20MB)

5. **ThemeConfiguration / 主题配置**
   - 字段 / Fields: selected_theme, theme_dir, fallback_theme, custom_icons_enabled
   - 来源 / Source: parsed from config.json or KlipperScreen.conf
   - 验证 / Validation: selected_theme must exist in available themes

### API 契约 / API Contracts

将从功能需求生成以下 API 契约到 /contracts/：
Will generate following API contracts from functional requirements to /contracts/:

**contracts/theme-api.yaml** (内部 Python API，非 HTTP)
(Internal Python API, not HTTP)

```yaml
# ThemeManager API
loadTheme(theme_name: str) -> Theme:
  description: 加载指定主题的所有素材 / Load all assets for specified theme
  parameters:
    theme_name: 主题名称（material-dark 等）/ Theme name
  returns: Theme 对象包含颜色和图标 / Theme object with colors and icons
  errors:
    ThemeNotFoundError: 主题目录不存在 / Theme directory not found
    ThemeLoadError: 主题素材加载失败 / Theme asset loading failed

parseThemeColors(css_file_path: str) -> ColorPalette:
  description: 从 CSS 文件解析颜色定义 / Parse color definitions from CSS file
  parameters:
    css_file_path: CSS 文件路径 / CSS file path
  returns: ColorPalette 对象 / ColorPalette object
  errors:
    FileNotFoundError: CSS 文件不存在 / CSS file not found
    ParseError: CSS 解析失败 / CSS parsing failed

# IconLoader API
loadIcon(icon_name: str, theme: Theme) -> IconAsset:
  description: 加载指定图标，优先使用缓存 / Load specified icon, prefer cache
  parameters:
    icon_name: 图标名称（不含扩展名）/ Icon name (without extension)
    theme: 当前主题 / Current theme
  returns: IconAsset 对象或回退占位符 / IconAsset object or fallback placeholder
  errors:
    IconNotFoundError: 图标文件不存在且无回退 / Icon not found and no fallback

preloadIcons(icon_names: List[str], theme: Theme) -> None:
  description: 预加载图标列表到缓存 / Preload icon list to cache
  parameters:
    icon_names: 图标名称列表 / Icon name list
    theme: 当前主题 / Current theme

# QML-exposed properties (via QObject)
ThemeProvider (QObject):
  properties:
    currentTheme: str (readable/writable)
    backgroundColor: str (readable)
    textColor: str (readable)
    color1, color2, color3, color4: str (readable)
    activeColor: str (readable)
    warningColor: str (readable)
    errorColor: str (readable)
  signals:
    themeChanged()
    themeLoadError(errorMessage: str)
```

### 快速启动指南 / Quickstart Guide

将创建 quickstart.md 包含：
Will create quickstart.md containing:

1. **开发环境设置 / Development Setup**
   - 安装 PySide6 和依赖 / Install PySide6 and dependencies
   - 克隆 KlipperScreen 仓库（用于素材）/ Clone KlipperScreen repo (for assets)
   - 配置主题路径 / Configure theme paths

2. **主题使用示例 / Theme Usage Examples**
   - 在 QML 中使用 ThemeProvider / Using ThemeProvider in QML
   - 显示主题化图标 / Displaying themed icons
   - 访问主题颜色 / Accessing theme colors

3. **添加自定义图标 / Adding Custom Icons**
   - 放置自定义 SVG 到主题目录 / Place custom SVG in theme directory
   - 在配置中引用自定义图标 / Reference custom icon in config

4. **测试主题切换 / Testing Theme Switching**
   - 修改配置文件 / Modify config file
   - 重启应用查看新主题 / Restart app to see new theme

### 代理上下文更新 / Agent Context Update

Phase 1 完成后将运行：
After Phase 1 completion will run:

```bash
.specify/scripts/bash/update-agent-context.sh claude
```

更新 `.claude/` 目录中的上下文文件，添加本功能的技术细节：
Update context file in `.claude/` directory, adding technical details for this feature:

- 主题管理技术栈（CSS 解析、QML 绑定）/ Theme management tech stack
- 图标加载模式（缓存、延迟加载）/ Icon loading patterns
- QML-Python 集成模式（信号槽、属性绑定）/ QML-Python integration patterns

**Phase 1 输出 / Phase 1 Outputs**:
- data-model.md
- contracts/theme-api.yaml
- quickstart.md
- 更新的 Claude 上下文文件 / Updated Claude context file

## Phase 2: 任务生成 / Task Generation

**注意 / Note**: Phase 2 由 `/speckit.tasks` 命令执行，不是 `/speckit.plan` 的一部分。
Phase 2 is executed by `/speckit.tasks` command, not part of `/speckit.plan`.

本计划文档在 Phase 1 后停止。继续使用 `/speckit.tasks` 生成 tasks.md。
This plan document stops after Phase 1. Continue with `/speckit.tasks` to generate tasks.md.

## 后续步骤 / Next Steps

1. ✅ 计划文档已创建 / Plan document created: plan.md
2. 🔄 执行 Phase 0 研究 / Execute Phase 0 research → research.md
3. ⏳ 执行 Phase 1 设计 / Execute Phase 1 design → data-model.md, contracts/, quickstart.md
4. ⏳ 重新检查宪章 / Re-check constitution after Phase 1
5. ⏳ 运行 `/speckit.tasks` 生成任务列表 / Run `/speckit.tasks` to generate task list

---

**计划状态 / Plan Status**: ✅ Phase 1 完成 / Phase 1 Complete
**下一个命令 / Next Command**: `/speckit.tasks` - 生成任务列表 / Generate task list

---

## Phase 0 & Phase 1 完成总结 / Phase 0 & Phase 1 Completion Summary

### ✅ Phase 0: 研究完成 / Research Complete

**生成的文件 / Generated Files:**
- ✅ `research.md` - 完整的技术研究报告，包含 4 个关键决策

**研究成果 / Research Findings:**
1. **Qt SVG 兼容性**: 98.1% KlipperScreen 图标可直接使用
2. **CSS 解析方案**: 正则表达式 + 递归解析（零依赖）
3. **资源路径策略**: file:// (开发) + qrc:// (生产可选)
4. **缓存策略**: QML 内置缓存 + 20MB QPixmapCache

### ✅ Phase 1: 设计完成 / Design Complete

**生成的文件 / Generated Files:**
- ✅ `data-model.md` - 5 个核心实体定义（Theme, ColorPalette, IconAsset, AssetCache, ThemeConfiguration）
- ✅ `contracts/theme-api.yaml` - 完整 API 契约（ThemeManager, IconLoader, CSSParser, ThemeProvider）
- ✅ `quickstart.md` - 4 步快速启动指南
- ✅ `.claude/` - 更新的 Claude 上下文文件

**设计亮点 / Design Highlights:**
- 5 个数据实体，清晰的关系图
- 完整的 Python 类接口定义
- QML-Python 集成模式（QObject 属性和槽）
- 性能保证：首次加载 <50ms，缓存加载 <5ms

### 🎯 下一步 / Next Steps

运行以下命令生成实施任务列表：
```bash
/speckit.tasks
```

任务将基于：
- 52 个功能需求 (spec.md)
- 4 个技术决策 (research.md)
- 5 个数据实体 (data-model.md)
- API 契约 (contracts/theme-api.yaml)
