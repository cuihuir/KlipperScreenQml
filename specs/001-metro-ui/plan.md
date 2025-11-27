# 实施计划：基于设计图的UI界面实现

**分支**: `001-metro-ui` | **日期**: 2025-11-20 | **规格**: [spec.md](./spec.md)

## 概要

实现基于PySide6+QML的3D打印机UI界面，严格遵循ui_design目录中的设计图。包含首页、控制、文件、设置四个主要页面，通过Moonraker API与Klipper打印机通信，支持实时状态监控、手动控制、文件管理和系统配置。

关键特性：
- 4个主要页面 + 打印状态/屏保页面
- 底部导航栏常驻（非全屏页面）
- 实时数据更新（WebSocket）
- 文件缩略图预览和多源浏览
- 温度/轴位置精确控制
- 8个占位符功能（UI完整，功能待实现）

## 技术上下文

**语言/版本**: Python 3.10.12 (项目当前版本)

**主要依赖**:
- PySide6 >= 6.5.0 (Qt6框架，QML引擎)
- websockets >= 11.0 (Moonraker WebSocket实时通信)
- aiohttp >= 3.9.0 (异步HTTP客户端)
- requests >= 2.31.0 (同步HTTP请求)

**存储**:
- 配置文件: JSON (config.json)
- 用户设置: JSON持久化
- 文件元数据: Moonraker API提供（G-code嵌入）

**测试**: pytest (Python单元测试) + Qt Test框架(QML组件测试 - 待引入)

**目标平台**:
- Linux嵌入式 (Orange Pi, Raspberry Pi) - X11
- WSL2 - Wayland
- 1920x440像素触摸屏

**项目类型**: Desktop (Qt/QML桌面应用)

**性能目标**:
- UI响应: 页面切换 < 300ms
- 实时更新: 数据刷新 < 2秒
- 文件列表: 100项渲染 < 500ms
- 触摸延迟: < 100ms

**约束**:
- 内存: < 200MB (嵌入式限制)
- 离线能力: 本地功能必须可用
- 单用户: 无认证系统
- 设计一致性: 95%视觉匹配度

**规模/范围**:
- 6个页面 (首页/控制/文件/设置/打印状态/屏保)
- 15-20个可复用QML组件
- 8个占位符功能
- 4种文件源

## 宪章检查

*门禁：Phase 0研究前通过，Phase 1设计后重新检查*

**注**: 项目宪章为模板状态，无具体原则。本功能遵循现有代码实践：

✅ **架构一致性**:
- 继承backend/(Python) + qml/(QML)分离架构
- 复用MoonrakerClient通信层
- 扩展ConfigManager设置管理

✅ **组件化设计**:
- QML组件注册在qmldir
- Python后端通过@Property/@Slot暴露
- 信号槽模式通信

✅ **无破坏性更改**:
- 新增页面不修改现有功能
- 配置格式向后兼容
- Moonraker API协议不变

**门禁结果**: ✅ 通过 - 无宪章违反

## 项目结构

### 文档 (本功能)

```text
specs/001-metro-ui/
├── spec.md              # 功能规格 (已完成)
├── plan.md              # 本文件
├── research.md          # Phase 0 输出
├── data-model.md        # Phase 1 输出
├── quickstart.md        # Phase 1 输出
├── contracts/           # Phase 1 输出
│   └── qml-python-api.md
├── checklists/
│   └── requirements.md  # 已完成
└── tasks.md             # Phase 2 (由/speckit.tasks生成)
```

### 源代码 (项目根目录)

```text
backend/
├── __init__.py
├── application.py       # [扩展] 新增页面属性暴露
├── config_manager.py    # [扩展] UI设置项
├── moonraker_client.py  # [扩展] 控制/文件管理方法
└── [新增] ui_state.py          # UI状态管理（导航/屏保）

qml/
├── MainWindow.qml       # [重构] 导航栏和页面切换
├── Style.qml            # [扩展] 设计图颜色定义
├── qmldir               # [扩展] 模块导出
├── components/
│   ├── qmldir           # [扩展] 组件注册
│   ├── [新增] BottomNavBar.qml    # 底部导航
│   ├── [新增] TempCard.qml        # 温度卡片
│   ├── [新增] AxisControl.qml     # 轴控制
│   ├── [新增] FileCard.qml        # 文件卡片
│   ├── [新增] PrintModeDialog.qml # 模式选择
│   ├── [新增] ConfirmDialog.qml   # 参数确认
│   └── [新增] PlaceholderToast.qml # 占位符提示
└── pages/
    ├── [新增] HomePage.qml         # 首页
    ├── [新增] ControlPage.qml     # 控制
    ├── [新增] FilesPage.qml       # 文件
    ├── [新增] SettingsPage.qml    # 设置
    ├── [新增] PrintingPage.qml    # 打印状态
    └── [新增] ScreenSaverPage.qml # 屏保

assets/
└── [新增] icons/                   # 导航/占位符图标

tests/
├── [新增] test_ui_state.py        # UI状态测试
└── [新增] qml/                     # QML组件测试(可选)
```

**结构决策**:

采用现有backend-qml分离架构（非Web/Mobile应用，无需backend/frontend分割）。新增功能通过扩展现有模块和添加新QML页面/组件实现。遵循Qt最佳实践：
- 页面放在qml/pages/
- 可复用组件在qml/components/
- 所有组件在qmldir中注册
- Python后端扩展Application类属性

## 复杂度跟踪

无需填写 - 无宪章违反。

## Phase 0: 研究与决策

### 需要研究的未知项

基于技术上下文和规格，以下领域需要研究决策：

1. **QML设计图颜色提取**
   - 问题: ui_design设计图中的颜色如何准确提取并定义为QML常量
   - 现状: Style.qml存在，但缺少具体颜色定义
   - 需调研: 图像颜色提取工具、QML Color定义最佳实践

2. **文件缩略图Base64显示**
   - 问题: G-code元数据中的Base64缩略图如何在QML Image中渲染
   - 现状: MoonrakerClient已获取元数据
   - 需调研: `image://` provider vs data URL、性能对比

3. **屏保空闲检测**
   - 问题: QML应用如何检测用户无操作并触发屏保
   - 需调研: EventFilter监听、QTimer实现、电源管理集成

4. **网络文件下载进度**
   - 问题: 如何实时反馈Moonraker文件下载进度到QML
   - 需调研: aiohttp进度回调、信号槽绑定、ProgressBar更新

5. **多页面共享状态**
   - 问题: 4个页面如何共享打印机状态而不重复订阅
   - 现状: Application类通过@Property暴露MoonrakerClient
   - 需调研: QML单例模式、StackView vs Loader性能

6. **1920x440宽屏适配**
   - 问题: 超宽比例屏幕(4.36:1)的布局适配策略
   - 需调研: QML锚点布局、Row/Grid最佳实践、触摸区域优化

7. **占位符统一实现**
   - 问题: 8个占位符功能如何统一Toast/Dialog提示
   - 需调研: QML Popup/ToolTip组件、信号日志记录

### 研究任务分配

将为每个未知项生成research.md条目，包括：
- 决策内容
- 理由
- 替代方案
- 代码示例

## Phase 1: 设计与合约

### 数据模型设计

将在`data-model.md`中定义：

**核心实体**:

1. **PrintFile** (打印文件)
   - 字段: filename, path, size, thumbnail_b64, metadata
   - 元数据: layers, est_time, temps, filament
   - 来源: Moonraker file API

2. **PrintJob** (打印任务)
   - 字段: file, progress, state, temps, z_pos
   - 状态: idle/printing/paused/complete/failed
   - 来源: Moonraker print_stats

3. **ControlState** (控制状态)
   - 字段: axis_pos, target_temps, current_temps, move_step
   - 验证: 温度范围、轴限制
   - 来源: Moonraker toolhead/heaters

4. **UIState** (UI状态)
   - 字段: current_page, screensaver_active, idle_timer
   - 验证: 页面枚举、超时范围

5. **AppSettings** (应用设置)
   - 字段: brightness, volume, language, timezone, screensaver_timeout
   - 持久化: config.json
   - 验证: 范围检查

### API合约

将在`contracts/qml-python-api.md`中定义：

**Python暴露接口**:

```python
# @Property
- printerState: str
- extruderTemp: dict {"current": float, "target": float}
- bedTemp: dict
- chamberTemp: dict
- filamentLevel: float
- recentPrint: dict
- fileList: list
- currentPage: str
- screensaverActive: bool

# @Slot
- setTemp(heater: str, temp: float)
- moveAxis(axis: str, dist: float)
- homeAxis(axes: str)
- extrude(length: float)
- startPrint(file_path: str, mode: str)
- pausePrint()
- resumePrint()
- cancelPrint()
- changePage(page: str)
- showPlaceholder(feature: str)
- setBrightness(value: int)
- setVolume(value: int)

# Signal
- tempUpdated(dict)
- fileListChanged(list)
- printProgressChanged(dict)
- pageChanged(str)
- placeholderClicked(str)
```

**QML调用示例**:
```qml
// 设置温度
printer.setTemp("extruder", 200)

// 移动轴
printer.moveAxis("Z", 10)

// 访问属性
Text { text: printer.extruderTemp.current }
```

### 快速启动指南

将在`quickstart.md`中包含：
- 项目结构导航
- 添加新QML组件步骤
- 添加Python控制命令步骤
- 测试QML页面方法
- 占位符实现模板

## 风险与依赖

### 技术风险

1. **QML性能** (中等)
   - 风险: Orange Pi渲染可能<60fps
   - 缓解: QML Profiler优化、ListModel虚拟化

2. **宽屏布局** (中等)
   - 风险: 1920x440超宽比例可能导致UI元素过度拉伸
   - 缓解: 使用Row布局横向分割、设置最大宽度约束

3. **Moonraker API稳定性** (低)
   - 风险: API变更
   - 缓解: 已有MoonrakerClient封装、版本检查

4. **设计图精度** (低)
   - 风险: 部分设计细节模糊
   - 缓解: 95%一致性标准允许合理调整

### 外部依赖

- Moonraker API (打印机通信)
- G-code元数据 (缩略图)
- 系统网络管理 (WiFi)
- X11/Wayland (显示)

### 阻塞项

无 - 所有依赖已集成

## 下一步

本文档完成后：

1. ✅ Phase 0: 生成`research.md` (解决7个研究任务)
2. ✅ Phase 1: 生成`data-model.md`和`contracts/qml-python-api.md`
3. ✅ Phase 1: 生成`quickstart.md`
4. ✅ Phase 1: 更新Agent上下文
5. ⏭️ Phase 2: 运行`/speckit.tasks`生成任务列表
6. 🚀 开始实施（按P1/P2/P3优先级）
