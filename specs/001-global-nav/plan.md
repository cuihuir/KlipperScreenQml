# 实现计划：iOS 风格全局导航与主页设计

**分支 (Branch)**: `001-global-nav` | **日期 (Date)**: 2025-11-27 | **规范 (Spec)**: [spec.md](./spec.md)
**输入 (Input)**: 功能规范来自 `/specs/001-global-nav/spec.md`

**注意 (Note)**: 本模板由 `/speckit.plan` 命令填充。执行工作流程参见 `.specify/templates/commands/plan.md`。

## 摘要 (Summary)

实现 iOS 风格的全局导航系统，包括主页设计和全局按钮（返回/Home）。主页将显示常用功能的 Widget（温度、风扇、LED、打印控制）和功能入口图标（设置、控制、文件等）。各功能页面全屏显示，左侧保留全局按钮空间。采用 PySide6 + QML 技术栈，通过信号槽机制实现前后端通信，集成 Moonraker API 实现打印机控制。

## 技术上下文 (Technical Context)

**语言/版本 (Language/Version)**: Python 3.10+
**主要依赖 (Primary Dependencies)**: PySide6 (>=6.5.0), QML, websockets (>=11.0), aiohttp (>=3.9.0), requests (>=2.31.0)
**存储 (Storage)**: 配置文件（JSON/INI），Moonraker API 作为数据源
**测试 (Testing)**: NEEDS CLARIFICATION（需要确定测试框架 - pytest for Python, QML test framework）
**目标平台 (Target Platform)**: Linux 触摸屏设备（1920x440 超宽屏，树莓派或类似硬件）
**项目类型 (Project Type)**: 单体应用（Desktop GUI Application）
**性能目标 (Performance Goals)**:
- UI 交互响应 < 200ms
- 导航切换 < 300ms
- Widget 状态更新 < 500ms
- 保持 60 FPS 流畅度
**约束 (Constraints)**:
- 触摸优先交互设计
- Metro 设计风格
- 左侧保留全局按钮空间（约 80-100px）
- 实时数据更新通过 WebSocket
**规模/范围 (Scale/Scope)**:
- 8-10 个主要页面
- 4-6 个主页 Widget
- 6-12 个功能图标
- 支持单打印机连接

## 宪章检查 (Constitution Check)

*门控 (GATE): 必须在 Phase 0 研究前通过。Phase 1 设计后重新检查。*

### ✅ 双语文档规范 (Bilingual Documentation Standard)

- **遵守情况**: ✅ PASS
- **说明**: 本功能的所有文档（spec.md, plan.md）均使用中文编写，符合宪章要求。技术术语保留英文以保证精确性。

### ✅ QML/Python 架构 (QML/Python Architecture)

- **遵守情况**: ✅ PASS
- **说明**: 本功能使用 QML 构建 UI（主页、Widget、全局按钮），使用 Python 处理后端逻辑（状态管理、API 调用），通过 PySide6 信号槽机制通信，完全符合架构要求。

### ✅ 渐进式开发 (Progressive Development)

- **遵守情况**: ✅ PASS
- **说明**: 功能规范中已明确定义了 8 个 P1 优先级用户故事，每个故事独立可测试，遵循 MVP 原则。实现将按优先级顺序进行。

### ✅ 提交前确认 (Commit Confirmation)

- **遵守情况**: ✅ PASS
- **说明**: 宪章要求"提交前必须向用户确认（不要直接提交代码）"，将在实现阶段严格遵守。

**结论**: 所有宪章门控 ✅ 通过，可以继续进行 Phase 0 研究。

---

## 宪章检查（Phase 1 后重新评估）

*门控 (GATE): Phase 1 设计完成后重新检查。*

### ✅ 双语文档规范 (Bilingual Documentation Standard)

- **遵守情况**: ✅ PASS
- **Phase 1 验证**: 所有生成的文档（research.md, data-model.md, contracts/**, quickstart.md）均使用中文编写，代码示例中保留英文标识符以确保技术精确性。

### ✅ QML/Python 架构 (QML/Python Architecture)

- **遵守情况**: ✅ PASS
- **Phase 1 验证**:
  - Python 后端：NavigationManager, MoonrakerClient 扩展（风扇/LED 控制）
  - QML 前端：StackView 导航、HomePage、Widget 组件
  - 通信机制：@Property + notify 信号、@Slot 方法
  - 完全符合 PySide6 信号槽架构

### ✅ 渐进式开发 (Progressive Development)

- **遵守情况**: ✅ PASS
- **Phase 1 验证**:
  - 8 个 P1 优先级用户故事已全部分解到数据模型和 API 契约
  - 每个功能独立可测试（单元测试示例已提供）
  - 遵循 MVP 原则（核心导航 + 基础 Widget）

### ✅ 提交前确认 (Commit Confirmation)

- **遵守情况**: ✅ PASS
- **Phase 1 验证**: 本次 plan 阶段未涉及代码提交，仅生成设计文档。实现阶段将严格遵守提交前确认原则。

**Phase 1 结论**: 所有宪章门控 ✅ 持续通过，可以继续进行 Phase 2（任务生成）和实现阶段。

## 项目结构 (Project Structure)

### 文档结构（本功能） / Documentation (this feature)

```text
specs/001-global-nav/
├── spec.md              # 功能规范（已完成）
├── plan.md              # 本文件 (/speckit.plan 命令输出)
├── research.md          # Phase 0 输出（待生成）
├── data-model.md        # Phase 1 输出（待生成）
├── quickstart.md        # Phase 1 输出（待生成）
├── contracts/           # Phase 1 输出（待生成）
│   ├── qml-python-api.md     # QML-Python 接口契约
│   ├── navigation-api.md      # 导航系统 API
│   └── widget-api.md          # Widget 交互 API
└── tasks.md             # Phase 2 输出 (/speckit.tasks 命令 - 不由 /speckit.plan 创建)
```

### 源代码结构（仓库根目录） / Source Code (repository root)

```text
QtKs/                    # 项目根目录
├── backend/             # Python 后端代码
│   ├── application.py         # 主应用类（已存在）
│   ├── moonraker_client.py    # Moonraker API 客户端（已存在）
│   ├── config_manager.py      # 配置管理（已存在）
│   ├── ui_state.py            # UI 状态管理（已存在）
│   ├── navigation_manager.py  # 导航管理器（待新建）
│   └── widget_controller.py   # Widget 控制器（待新建）
│
├── qml/                 # QML 前端代码
│   ├── MainWindow.qml          # 主窗口（已存在）
│   ├── Style.qml               # Metro 样式定义（已存在）
│   │
│   ├── pages/                  # 页面组件
│   │   ├── HomePage.qml              # 主页（待新建/重构）
│   │   ├── ControlPage.qml           # 控制页（已存在）
│   │   ├── FilesPage.qml             # 文件页（已存在）
│   │   ├── SettingsPage.qml          # 设置页（已存在）
│   │   ├── PrintingPage.qml          # 打印详情页（已存在）
│   │   └── ScreenSaverPage.qml       # 屏保页（已存在）
│   │
│   └── components/             # UI 组件
│       ├── GlobalNavButtons.qml      # 全局导航按钮（待新建）
│       ├── HomeWidget.qml            # 主页 Widget 基类（待新建）
│       ├── TempWidget.qml            # 温度 Widget（待新建）
│       ├── FanWidget.qml             # 风扇 Widget（待新建）
│       ├── LedWidget.qml             # LED Widget（待新建）
│       ├── PrintControlWidget.qml    # 打印控制 Widget（待新建）
│       ├── FunctionIcon.qml          # 功能图标（待新建）
│       ├── NumericKeypad.qml         # 数字键盘（已存在，可能需要调整）
│       ├── MetroButton.qml           # Metro 按钮（已存在）
│       └── qmldir                    # QML 模块定义（已存在）
│
├── assets/              # 资源文件
│   └── icons/                 # 图标资源（待补充）
│
├── main.py              # 应用入口（已存在）
├── requirements.txt     # Python 依赖（已存在）
└── config.json          # 配置文件（已存在）
```

**结构决策说明 (Structure Decision)**:

本项目采用 **单体桌面应用架构**，由 Python 后端和 QML 前端组成：

1. **Backend 模块** (`backend/`):
   - 使用 PySide6 的 QObject 暴露 Python 对象给 QML
   - 新增 `navigation_manager.py` 管理页面导航栈和历史
   - 新增 `widget_controller.py` 管理 Widget 状态和数据更新

2. **QML 模块** (`qml/`):
   - `pages/` 存放全屏页面组件（HomePage 是核心新增页面）
   - `components/` 存放可复用 UI 组件（全局按钮、Widget 等）
   - 使用 Metro 设计风格（`Style.qml`）

3. **现有代码复用**:
   - `MainWindow.qml`：作为容器，集成全局导航系统
   - `application.py`：扩展以支持 UI 状态同步
   - `NumericKeypad.qml`：用于温度输入键盘

## 复杂度追踪 (Complexity Tracking)

> **仅在宪章检查有违规需要说明时填写**

**本功能无宪章违规，此部分留空。**
