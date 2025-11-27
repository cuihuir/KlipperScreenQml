# 数据模型：iOS 风格全局导航与主页设计

**功能分支**: `001-global-nav`
**创建日期**: 2025-11-27
**状态**: Phase 1 完成

## 模型概述

本文档定义了 iOS 风格全局导航系统和主页设计所需的核心数据实体、它们的属性、关系和状态转换。

---

## 核心实体 (Core Entities)

### 1. NavigationManager (导航管理器)

**职责**: 管理页面导航栈和历史记录

**属性 (Properties)**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `currentDepth` | `int` | ✅ | `1` | 当前导航栈深度 |
| `currentPage` | `str` | ✅ | `"home"` | 当前页面标识符 |
| `canGoBack` | `bool` | ✅ | `false` | 是否可以返回上一级 |
| `navigationHistory` | `list[str]` | ✅ | `["home"]` | 导航历史栈（页面 ID 列表） |

**方法 (Methods)**:

```python
@Slot(str)
def pushPage(page_id: str) -> None:
    """推送新页面到导航栈"""

@Slot()
def popPage() -> None:
    """弹出当前页面，返回上一级"""

@Slot()
def popToRoot() -> None:
    """弹出所有页面，返回主页"""

@Slot(int)
def popToDepth(depth: int) -> None:
    """弹出到指定深度"""
```

**信号 (Signals)**:

```python
navigationChanged = Signal(str, int)  # (page_id, depth)
pageEntered = Signal(str)             # page_id
pageExited = Signal(str)              # page_id
```

**状态转换**:

```
[主页] --pushPage()--> [功能页]
       <--popPage()--

[主页] --pushPage()--> [功能页] --pushPage()--> [子页面]
       <------------------popToRoot()------------------
```

---

### 2. HomePage (主页)

**职责**: 应用入口页面，显示 Widget 和功能图标

**属性 (Properties)**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `widgets` | `list[Widget]` | ✅ | `[]` | 主页 Widget 列表 |
| `functionIcons` | `list[FunctionIcon]` | ✅ | `[]` | 功能图标列表 |
| `layoutMode` | `str` | ❌ | `"row"` | 布局模式（"row" 或 "grid"） |

**组件结构** (QML):

```qml
HomePage {
    RowLayout {
        // 左侧 60%：Widget 区域
        WidgetArea {
            widgets: [
                TempWidget,
                FanWidget,
                LedWidget,
                PrintControlWidget
            ]
        }

        // 右侧 40%：功能图标区域
        IconGrid {
            icons: [
                "设置", "控制", "文件",
                "AFC", "移动", "更多"
            ]
        }
    }
}
```

---

### 3. Widget (基础 Widget)

**职责**: 主页可交互卡片的基类

**属性 (Properties)**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `widgetId` | `str` | ✅ | `""` | Widget 唯一标识符 |
| `title` | `str` | ❌ | `""` | Widget 标题 |
| `state` | `str` | ✅ | `"idle"` | Widget 状态（见下表） |
| `isInteractive` | `bool` | ✅ | `true` | 是否可交互 |
| `lastUpdateTime` | `float` | ✅ | `0.0` | 最后更新时间戳 |

**Widget 状态枚举**:

| 状态 | 值 | 描述 | 视觉表现 |
|------|-----|------|----------|
| `IDLE` | `"idle"` | 空闲状态 | 正常显示 |
| `ACTIVE` | `"active"` | 活动状态（用户交互中） | 高亮边框/背景 |
| `UPDATING` | `"updating"` | 数据更新中 | 加载指示器 |
| `ERROR` | `"error"` | 错误状态 | 红色边框 + 错误图标 |

**状态转换图**:

```
      ┌──────────┐
      │   IDLE   │ ◄────────────┐
      └──────────┘              │
           │ ▲                  │
    点击   │ │ 更新完成/取消     │
           ▼ │                  │
      ┌──────────┐              │
      │  ACTIVE  │              │
      └──────────┘              │
           │                    │
    触发操作                     │
           │                    │
           ▼                    │
      ┌──────────┐        ┌─────────┐
      │ UPDATING │───────▶│  ERROR  │
      └──────────┘ 失败    └─────────┘
           │                    │
           └────────────────────┘
              更新成功
```

---

### 4. TempWidget (温度 Widget)

**继承**: `Widget`

**职责**: 显示和控制温度（喷头/热床）

**扩展属性**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `heaterName` | `str` | ✅ | `"extruder"` | 加热器名称 |
| `currentTemp` | `float` | ✅ | `0.0` | 当前温度（°C） |
| `targetTemp` | `float` | ✅ | `0.0` | 目标温度（°C） |
| `maxTemp` | `int` | ✅ | `300` | 最大允许温度 |
| `isHeating` | `bool` | ✅ | `false` | 是否正在加热 |
| `keypadVisible` | `bool` | ❌ | `false` | 键盘是否可见 |

**方法**:

```python
@Slot(int)
def setTargetTemp(temp: int) -> None:
    """设置目标温度"""

@Slot()
def showKeypad() -> None:
    """显示数字键盘"""

@Slot()
def hideKeypad() -> None:
    """隐藏数字键盘"""
```

**信号**:

```python
tempChanged = Signal(float, float)  # (current, target)
heatingStateChanged = Signal(bool)  # isHeating
```

**数据流**:

```
Moonraker WebSocket (温度更新)
    ↓
MoonrakerClient._update_from_status()
    ↓ (节流：≥ 0.5°C)
temperatureUpdated Signal
    ↓
TempWidget.currentTemp (自动绑定)
    ↓
QML Label 显示更新
```

---

### 5. FanWidget / LedWidget (风扇/LED Widget)

**继承**: `Widget`

**职责**: 控制风扇速度和 LED 亮度

**扩展属性**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `deviceName` | `str` | ✅ | `""` | 设备名称 |
| `isOn` | `bool` | ✅ | `false` | 是否开启 |
| `level` | `float` | ✅ | `0.0` | 级别（0.0-1.0，对应速度/亮度） |
| `maxLevel` | `float` | ✅ | `1.0` | 最大级别 |

**方法**:

```python
@Slot(bool)
def setOnOff(on: bool) -> None:
    """开关设备"""

@Slot(float)
def setLevel(level: float) -> None:
    """设置级别（0.0-1.0）"""
```

**信号**:

```python
stateChanged = Signal(bool, float)  # (isOn, level)
```

---

### 6. PrintControlWidget (打印控制 Widget)

**继承**: `Widget`

**职责**: 显示打印状态和控制打印流程

**扩展属性**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `printState` | `str` | ✅ | `"idle"` | 打印状态（见下表） |
| `progress` | `float` | ✅ | `0.0` | 打印进度（0.0-100.0） |
| `currentLayer` | `int` | ✅ | `0` | 当前图层 |
| `totalLayers` | `int` | ✅ | `0` | 总图层数 |
| `fileName` | `str` | ✅ | `""` | 打印文件名 |
| `estimatedTimeRemaining` | `int` | ✅ | `0` | 预计剩余时间（秒） |
| `thumbnailPath` | `str` | ✅ | `""` | 缩略图路径 |

**打印状态枚举**:

| 状态 | 值 | 描述 | UI 表现 |
|------|-----|------|---------|
| `IDLE` | `"idle"` | 空闲（未打印） | 显示"开始打印"超大按钮 |
| `PRINTING` | `"printing"` | 打印中 | 显示进度卡片 + 暂停/取消按钮 |
| `PAUSED` | `"paused"` | 已暂停 | 显示进度卡片 + 继续/取消按钮 |
| `COMPLETE` | `"complete"` | 打印完成 | 显示完成信息 → 3秒后回到 IDLE |
| `CANCELLED` | `"cancelled"` | 已取消 | 显示取消信息 → 立即回到 IDLE |
| `ERROR` | `"error"` | 打印错误 | 显示错误信息 + 重试按钮 |

**状态转换图**:

```
        ┌──────────┐
        │   IDLE   │ ◄─────────────┐
        └──────────┘               │
             │                     │
    点击"开始打印"          打印完成/取消
             │                     │
             ▼                     │
        ┌──────────┐               │
        │ PRINTING │               │
        └──────────┘               │
         │      │                  │
   暂停  │      │ 完成              │
         │      │                  │
         ▼      ▼                  │
    ┌────────┐ ┌─────────┐        │
    │ PAUSED │ │COMPLETE │────────┘
    └────────┘ └─────────┘
         │          (3秒后)
    继续  │
         │
         └───────────┐
                     │
         ┌───────────┘
         │
         ▼
    ┌──────────┐
    │  ERROR   │
    └──────────┘
```

**方法**:

```python
@Slot(str)
def startPrint(filename: str) -> None:
    """开始打印"""

@Slot()
def pausePrint() -> None:
    """暂停打印"""

@Slot()
def resumePrint() -> None:
    """继续打印"""

@Slot()
def cancelPrint() -> None:
    """取消打印"""

@Slot()
def openPrintDetails() -> None:
    """打开打印详情页（全屏）"""
```

**信号**:

```python
printStateChanged = Signal(str)          # printState
progressChanged = Signal(float)          # progress
layerChanged = Signal(int, int)          # (currentLayer, totalLayers)
estimatedTimeChanged = Signal(int)       # estimatedTimeRemaining
```

**点击区域定义**:

```qml
PrintControlWidget {
    // 区域 1：暂停/取消按钮（高 z-order）
    Row {
        Button { text: "暂停"; z: 10 }
        Button { text: "取消"; z: 10 }
    }

    // 区域 2：卡片其他区域（低 z-order）
    MouseArea {
        anchors.fill: parent
        z: 0
        onClicked: openPrintDetails()  // 进入打印详情页
    }
}
```

---

### 7. FunctionIcon (功能图标)

**职责**: 主页功能入口图标

**属性**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `iconId` | `str` | ✅ | `""` | 图标唯一标识符 |
| `label` | `str` | ✅ | `""` | 图标标签 |
| `iconPath` | `str` | ✅ | `""` | 图标图片路径 |
| `targetPage` | `str` | ✅ | `""` | 目标页面 ID |
| `isEnabled` | `bool` | ✅ | `true` | 是否启用 |

**方法**:

```python
@Slot()
def navigate() -> None:
    """导航到目标页面"""
```

**信号**:

```python
clicked = Signal(str)  # iconId
```

**标准功能图标列表**:

| 图标 ID | 标签 | 目标页面 | 图标路径 |
|---------|------|----------|----------|
| `settings` | "设置" | `SettingsPage.qml` | `assets/icons/settings.svg` |
| `control` | "控制" | `ControlPage.qml` | `assets/icons/control.svg` |
| `files` | "文件" | `FilesPage.qml` | `assets/icons/files.svg` |
| `afc` | "AFC" | `AfcPage.qml` | `assets/icons/afc.svg` |
| `move` | "移动" | `MovePage.qml` | `assets/icons/move.svg` |
| `more` | "更多" | `MorePage.qml` | `assets/icons/more.svg` |

---

### 8. GlobalNavButtons (全局导航按钮)

**职责**: 固定的 HOME/Return 按钮

**属性**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `returnEnabled` | `bool` | ✅ | `false` | Return 按钮是否启用 |
| `homeEnabled` | `bool` | ✅ | `true` | Home 按钮是否启用（始终 true） |
| `currentDepth` | `int` | ✅ | `1` | 当前导航深度（绑定到 NavigationManager） |

**方法**:

```python
# 按钮点击直接调用 NavigationManager 方法
onHomeClicked: navigationManager.popToRoot()
onReturnClicked: navigationManager.popPage()
```

**状态规则**:

```python
returnEnabled = currentDepth > 1  # 仅在深度 > 1 时启用
homeEnabled = true                # 始终启用
```

---

### 9. NumericKeypad (数字键盘)

**职责**: 温度输入浮层

**属性**:

| 属性名 | 类型 | 只读 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `title` | `str` | ❌ | `""` | 键盘标题 |
| `inputValue` | `str` | ✅ | `""` | 当前输入值 |
| `maxLength` | `int` | ❌ | `3` | 最大输入长度 |
| `placeholder` | `str` | ❌ | `"000"` | 占位符 |

**方法**:

```qml
function appendDigit(digit: int) -> void
function deleteDigit() -> void
function clear() -> void
```

**信号**:

```qml
signal confirmed(string value)  // 用户点击确定
signal cancelled()              // 用户点击取消或背景
```

**交互流程**:

```
用户点击温度 Widget
    ↓
TempWidget.showKeypad()
    ↓
Popup 打开（非模态 + 背景变暗）
    ↓
用户输入数字
    ↓
用户点击确定
    ↓
confirmed(value) 信号发射
    ↓
TempWidget.setTargetTemp(value)
    ↓
MoonrakerClient.setExtruderTemp(heater, temp)
    ↓
Popup 关闭
```

---

## 数据流图 (Data Flow Diagram)

### 实时数据更新流程

```
┌──────────────────────────────────────────┐
│ Moonraker WebSocket                      │
│ (每秒多次推送状态更新)                    │
└─────────────┬────────────────────────────┘
              │ JSON-RPC notify_status_update
              ▼
┌──────────────────────────────────────────┐
│ WebSocketThread (QThread)                │
│ - asyncio 事件循环                        │
│ - messageReceived.emit(json_str)         │
└─────────────┬────────────────────────────┘
              │ 跨线程信号
              ▼
┌──────────────────────────────────────────┐
│ MoonrakerClient._on_ws_message()         │
│ - 解析 JSON                               │
│ - 节流逻辑:                               │
│   * 温度: ≥ 0.5°C 变化                    │
│   * 进度: ≥ 1 秒间隔                      │
│   * 图层: 值变化                          │
│ - 更新内部属性 (_extruder_temp, etc.)     │
│ - 发射 notify 信号                        │
└─────────────┬────────────────────────────┘
              │ temperatureUpdated
              │ printProgressChanged
              │ printStatsUpdated
              ▼
┌──────────────────────────────────────────┐
│ QML Widget 属性绑定                       │
│ TempWidget {                              │
│   currentTemp: printer.extruderTemp       │
│ }                                         │
│ PrintControlWidget {                      │
│   progress: printer.printProgress         │
│ }                                         │
└──────────────────────────────────────────┘
```

### 用户操作流程

```
┌──────────────────────────────────────────┐
│ 用户交互 (QML)                            │
│ - 点击 Widget                             │
│ - 点击功能图标                            │
│ - 点击全局按钮                            │
└─────────────┬────────────────────────────┘
              │ 调用 @Slot 方法
              ▼
┌──────────────────────────────────────────┐
│ Python 后端                               │
│ - MoonrakerClient.setExtruderTemp()       │
│ - MoonrakerClient.startPrint()            │
│ - NavigationManager.pushPage()            │
└─────────────┬────────────────────────────┘
              │ HTTP POST / JSON-RPC
              ▼
┌──────────────────────────────────────────┐
│ Moonraker API                             │
│ - 执行 G-code 命令                        │
│ - 更新打印机状态                          │
└─────────────┬────────────────────────────┘
              │ WebSocket 状态推送
              ▼
        (回到实时数据更新流程)
```

---

## 数据验证规则 (Validation Rules)

### 温度输入验证

| 字段 | 规则 | 错误提示 |
|------|------|----------|
| `targetTemp` | `0 <= value <= maxTemp` | "温度必须在 0-{maxTemp}°C 之间" |
| `targetTemp` | 必须为整数 | "请输入整数温度值" |

### 导航栈验证

| 字段 | 规则 | 处理 |
|------|------|------|
| `depth` | `>= 1` | 始终保持至少一个页面（主页） |
| `depth` | `<= 10` | 超过 10 层时警告（防止无限嵌套） |

### Widget 状态验证

| 字段 | 规则 | 处理 |
|------|------|------|
| `state` | 必须是合法状态枚举值 | 默认回退到 `"idle"` |
| `progress` | `0.0 <= value <= 100.0` | 钳制到有效范围 |

---

## 性能优化策略

### 1. 数据节流 (Throttling)

| 数据类型 | 策略 | 实现位置 |
|---------|------|----------|
| 温度 | 变化 ≥ 0.5°C | `MoonrakerClient._update_from_status()` |
| 进度 | 时间间隔 ≥ 1s | `MoonrakerClient._update_from_status()` |
| 图层 | 值变化时 | `MoonrakerClient._update_from_status()` |

### 2. UI 更新优化

| 技术 | 应用场景 | 效果 |
|------|---------|------|
| `SmoothedAnimation` | 温度数字显示 | 平滑过渡，避免跳变 |
| `Behavior on opacity` | 状态切换 | 淡入淡出过渡 |
| `z-order` 分层 | 点击区域 | 优先处理高优先级区域，减少判断 |

### 3. 内存管理

| 策略 | 应用 | 理由 |
|------|------|------|
| Component 实例化 | 功能页面 | pop 时自动销毁 |
| 预实例化 | HomePage, 全局按钮 | 常驻内存，快速切换 |
| 生命周期清理 | `onDeactivated`, `onRemoved` | 停止定时器、释放资源 |

---

## 扩展性考虑

### 未来可能的 Widget 类型

| Widget 类型 | 数据源 | 优先级 |
|------------|--------|--------|
| `CameraWidget` | Webcam 流 | P2 |
| `GCodeConsole` | G-code 输出 | P2 |
| `SystemMonitorWidget` | 系统资源 (CPU/RAM/温度) | P3 |
| `NotificationWidget` | Moonraker 通知 | P2 |

### 主页布局可配置性

未来可能支持：
- Widget 位置自定义（拖拽）
- Widget 可见性开关
- 功能图标排序

**预留字段**:
```python
# HomePage
layout_config: dict = {
    "widgets": [
        {"id": "temp", "position": (0, 0), "visible": true},
        {"id": "fan", "position": (1, 0), "visible": true}
    ],
    "icons": ["settings", "control", "files"]  # 排序
}
```

---

## 总结

本数据模型定义了：
- ✅ 9 个核心实体（NavigationManager, HomePage, Widget 及其子类, FunctionIcon, GlobalNavButtons, NumericKeypad）
- ✅ 完整的属性、方法、信号定义
- ✅ 状态机和状态转换规则
- ✅ 数据流图和验证规则
- ✅ 性能优化策略
- ✅ 扩展性预留

**下一步**: 基于此数据模型，Phase 1 将生成 API 契约文档（contracts/），定义 QML-Python 接口的具体实现规范。
