# 研究文档：iOS 风格全局导航与主页设计

**功能分支**: `001-global-nav`
**创建日期**: 2025-11-27
**状态**: Phase 0 完成

## 研究概述

本文档记录了为实现 iOS 风格全局导航系统和主页设计所做的技术研究。研究重点包括：

1. QML 导航模式（使用固定全局按钮，无边缘滑动手势）
2. QML Widget 数据绑定与实时更新模式
3. Metro 设计风格在 QML 中的实现

## 1. QML 导航模式（StackView + 固定按钮）

### 决策 (Decision)

使用 **QML StackView**（来自 Qt Quick Controls）配合**固定的全局按钮**（HOME/Return）实现 iOS 风格导航。

**关键点**：
- ✅ 使用 StackView 管理页面导航栈
- ✅ 全局按钮位于 StackView **外部**（左侧固定区域）
- ❌ **不使用边缘滑动手势**，避免手势冲突

### 理由 (Rationale)

1. **内置导航历史**: StackView 自动维护 LIFO（后进先出）栈，完美支持 iOS 风格的层级导航和返回按钮
2. **生命周期管理**: 提供丰富的生命周期信号（`onActivating`, `onActivated`, `onDeactivating`, `onDeactivated`, `onRemoved`）
3. **内存管理**: 自动处理组件的创建/销毁，同时支持手动控制
4. **深度追踪**: `depth` 属性简化按钮状态管理（例如：当 `depth === 1` 时禁用 Return 按钮）
5. **避免手势冲突**: 使用明确的按钮控制，不依赖边缘滑动手势

### 考虑的替代方案 (Alternatives Considered)

| 方案 | 优点 | 缺点 | 结论 |
|------|------|------|------|
| **StackLayout** | 简单、轻量 | 无历史栈、无生命周期、仅平级切换 | ❌ 不适合层级导航 |
| **自定义 Loader** | 最大灵活性 | 需手动实现栈、生命周期、转场 | ❌ 重复造轮子 |
| **SwipeView** | 手势友好 | 为横向滑动设计，不适合层级导航 | ❌ 交互模型不匹配 |

### 代码模式 (Code Patterns)

#### 基础结构：固定按钮 + StackView

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1920
    height: 440

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 左侧：全局导航按钮（固定）
        Column {
            id: globalNav
            Layout.preferredWidth: 80
            Layout.fillHeight: true
            spacing: 20
            padding: 20
            z: 100  // 始终在顶层

            Button {
                text: "HOME"
                width: parent.width - parent.padding * 2
                onClicked: stackView.pop(null)  // 清空栈，返回根页面
            }

            Button {
                text: "RETURN"
                width: parent.width - parent.padding * 2
                enabled: stackView.depth > 1  // 仅在深度 > 1 时启用
                onClicked: stackView.pop()
            }
        }

        // 右侧：主内容区（StackView）
        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            initialItem: homePageComponent

            // 自定义转场动画
            pushEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: 200
                }
            }

            popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: 200
                }
            }
        }

        Component {
            id: homePageComponent
            HomePage {}
        }
    }
}
```

#### 页面导航：从主页进入功能页

```qml
// HomePage.qml
Page {
    id: homePage
    property StackView stackView: StackView.view  // 访问父 StackView

    GridLayout {
        anchors.centerIn: parent
        columns: 4
        rowSpacing: 20
        columnSpacing: 20

        // 功能图标：设置
        Rectangle {
            width: 120
            height: 120
            color: "lightgray"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    stackView.push("qrc:/pages/SettingsPage.qml")
                }
            }
        }

        // 功能图标：控制
        Rectangle {
            width: 120
            height: 120
            color: "lightgray"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    stackView.push(controlPageComponent)
                }
            }
        }
    }
}
```

#### 生命周期管理

```qml
// SettingsPage.qml
Page {
    id: settingsPage

    // 生命周期钩子
    StackView.onActivating: {
        console.log("设置页正在激活")
    }

    StackView.onActivated: {
        console.log("设置页已激活 - 加载数据")
        refreshSettings()
    }

    StackView.onDeactivating: {
        console.log("设置页正在停用 - 保存状态")
        saveState()
    }

    StackView.onDeactivated: {
        console.log("设置页已停用 - 停止定时器")
        stopTimers()
    }

    StackView.onRemoved: {
        console.log("设置页已从栈中移除 - 清理资源")
        cleanup()
    }
}
```

#### 内存管理策略

```qml
StackView {
    id: stackView

    // ✅ 策略 1：使用 Component（自动销毁）
    function navigateToSettings() {
        stackView.push(settingsComponent)  // pop 时自动销毁
    }

    // ✅ 策略 2：使用 URL（自动销毁）
    function navigateToControl() {
        stackView.push("qrc:/pages/ControlPage.qml")  // pop 时自动销毁
    }

    // ⚠️ 策略 3：预实例化（不销毁）- 仅用于主页等常驻页面
    property Page homePage: HomePage { }

    Component.onCompleted: {
        stackView.push(homePage)  // 主页保持在内存中
    }
}
```

### 实现要点

1. **全局按钮位置**：放在 StackView **外部**（作为兄弟元素），确保始终可见
2. **Return 按钮状态**：使用 `stackView.depth > 1` 控制启用/禁用
3. **页面实例化**：使用 Component 或 URL 以启用自动销毁
4. **生命周期信号**：使用 `onActivated`/`onDeactivated` 管理定时器和资源
5. **转场时间**：保持在 300ms 以下以确保响应性
6. **访问 StackView**：使用 `StackView.view` 附加属性从子页面访问

---

## 2. QML Widget 数据绑定与实时更新

### 决策 (Decision)

使用 **只读 @Property + notify 信号**（Python → QML）和 **@Slot 装饰器**（QML → Python）实现数据绑定。

**架构流程**：
```
WebSocket (QThread)
  → Signal 发射
  → Python 属性更新 + notify 信号
  → QML 自动绑定更新
```

### 理由 (Rationale)

1. **单向数据流**: 只读属性防止 QML 意外修改后端状态
2. **自动更新**: notify 信号触发 QML 属性绑定自动刷新，无需手动连接
3. **最小耦合**: QML 不需要知道数据来源（WebSocket、REST、本地），只绑定属性
4. **线程安全**: Qt 信号槽机制自动处理跨线程通信

### 代码模式 (Code Patterns)

#### Python 后端：属性定义与信号

```python
from PySide6.QtCore import QObject, Signal, Property, Slot
import time

class MoonrakerClient(QObject):
    # 1. 先声明信号（必须在 __init__ 之前）
    temperatureUpdated = Signal(dict)
    printProgressChanged = Signal(dict)

    def __init__(self):
        super().__init__()
        self._extruder_temp = 0.0
        self._bed_temp = 0.0
        self._print_progress = 0.0
        self._last_progress_update_time = 0

    # 2. 定义只读属性（带 notify 信号）
    @Property(float, notify=temperatureUpdated)
    def extruderTemp(self):
        return self._extruder_temp

    @Property(float, notify=temperatureUpdated)
    def bedTemp(self):
        return self._bed_temp

    @Property(float, notify=printProgressChanged)
    def printProgress(self):
        return self._print_progress

    # 3. 内部更新方法（带节流逻辑）
    def _update_from_status(self, status: dict):
        updated = False

        # 温度节流：变化 >= 0.5°C 才更新
        if 'extruder' in status:
            new_temp = round(status['extruder']['temperature'], 1)
            if abs(new_temp - self._extruder_temp) >= 0.5:
                self._extruder_temp = new_temp
                updated = True

        if updated:
            self.temperatureUpdated.emit({
                'extruder_temp': self._extruder_temp,
                'bed_temp': self._bed_temp
            })

        # 进度节流：时间间隔 >= 1 秒才更新
        if 'virtual_sdcard' in status:
            current_time = time.time()
            new_progress = round(status['virtual_sdcard']['progress'] * 100, 1)
            if (new_progress != self._print_progress and
                current_time - self._last_progress_update_time >= 1.0):
                self._print_progress = new_progress
                self._last_progress_update_time = current_time
                self.printProgressChanged.emit({'progress': new_progress})

    # 4. QML 调用的方法（使用 @Slot）
    @Slot(str, int)
    def setExtruderTemp(self, heater_name: str, target_temp: int):
        """设置加热器目标温度"""
        # 发送到 Moonraker API
        self._send_gcode(f"SET_HEATER_TEMPERATURE HEATER={heater_name} TARGET={target_temp}")

    @Slot(str)
    def startPrint(self, filename: str):
        """开始打印"""
        self._send_gcode(f"SDCARD_PRINT_FILE FILENAME={filename}")
```

#### QML 前端：属性绑定

```qml
// TempWidget.qml - 温度 Widget
Rectangle {
    id: tempWidget
    width: 200
    height: 100

    Column {
        spacing: 10

        // ✅ 自动绑定：temperatureUpdated 信号触发时自动更新
        Label {
            text: "喷头: " + printer.extruderTemp.toFixed(1) + "°C"
            color: Style.getTempColor(printer.extruderTemp, 250)
        }

        Label {
            text: "热床: " + printer.bedTemp.toFixed(1) + "°C"
            color: Style.getTempColor(printer.bedTemp, 100)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: tempKeypad.open()
    }

    // 温度输入键盘（弹出层）
    Popup {
        id: tempKeypad
        anchors.centerIn: parent
        width: 400
        height: 500

        modal: false  // 非模态：允许背景继续更新
        dim: true     // 背景变暗
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        NumericKeypad {
            anchors.fill: parent
            title: "设置喷头温度"

            onConfirmed: function(value) {
                // ✅ 调用 Python 方法
                printer.setExtruderTemp("extruder", parseInt(value))
                tempKeypad.close()
            }

            onCancelled: {
                tempKeypad.close()
            }
        }
    }
}
```

#### WebSocket 数据流架构

```
┌──────────────────────────────────────────┐
│ Moonraker Server (Klipper)              │
└─────────────┬────────────────────────────┘
              │ WebSocket (JSON-RPC)
              ▼
┌──────────────────────────────────────────┐
│ WebSocketThread (QThread - 工作线程)     │
│ - 运行 asyncio 事件循环                  │
│ - 接收 JSON-RPC 通知                     │
│ - 解析消息                               │
│   ├─> notify_status_update               │
│   ├─> notify_gcode_response              │
│   └─> RPC 响应                           │
└─────────────┬────────────────────────────┘
              │ emit messageReceived(str)
              ▼
┌──────────────────────────────────────────┐
│ MoonrakerClient._on_ws_message()         │
│ (主线程)                                 │
│ - JSON 解析                              │
│ - 节流逻辑（温度 0.5°C，进度 1s）        │
│ - 更新缓存属性                           │
│ - 发射信号（temperatureUpdated 等）      │
└─────────────┬────────────────────────────┘
              │ Property notify 信号
              ▼
┌──────────────────────────────────────────┐
│ QML 属性绑定（主线程）                   │
│ Label { text: printer.extruderTemp }     │
│ ProgressBar { value: printer.progress }  │
│ TempControl { temp: printer.extruderTemp }│
└──────────────────────────────────────────┘
```

### 节流策略 (Throttling)

| 数据类型 | 更新频率 | 节流条件 | 理由 |
|---------|---------|---------|------|
| 温度 | ~1 Hz | ≥ 0.5°C 变化 | 小波动无意义，减少 UI 刷新 |
| 打印进度 | ~1 Hz | ≥ 1 秒间隔 | 避免每个 WebSocket 消息都更新 |
| 打印统计 | ~0.5 Hz | 图层变化 | 图层切换才有意义 |
| 位置 | ~10 Hz | 无节流 | 移动控制需要高频更新 |

### 交互式覆盖层 (Interactive Overlays)

#### 决策：非模态 Popup + 背景变暗

```qml
Rectangle {
    id: widget

    MouseArea {
        anchors.fill: parent
        onClicked: keypadPopup.open()
    }

    Popup {
        id: keypadPopup
        anchors.centerIn: parent
        width: 400
        height: 500

        modal: false  // ❌ 不阻塞背景
        dim: true     // ✅ 背景变暗 80%
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        z: 100

        // 入场动画
        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0.0; to: 1.0
                duration: 200
            }
            NumberAnimation {
                property: "scale"
                from: 0.8; to: 1.0
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        // 出场动画
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1.0; to: 0.0
                duration: 150
            }
        }

        NumericKeypad {
            anchors.fill: parent
            onConfirmed: keypadPopup.close()
            onCancelled: keypadPopup.close()
        }
    }
}
```

**为什么选择非模态**：
- ✅ 允许背景状态指示器（温度、进度）继续更新
- ✅ 用户可以看到温度升高的同时设置目标温度
- ❌ 模态 Popup 会冻结所有背景输入和更新

### 点击区域处理 (Click Area Handling)

#### 决策：分离的 MouseArea + 显式 z-order

```qml
// 文件卡片：信息区域 + 打印按钮
Rectangle {
    id: fileCard
    width: 300
    height: 200

    // ========== 信息区域（整个卡片）==========
    MouseArea {
        id: infoArea
        anchors.fill: parent
        hoverEnabled: true
        z: 0  // 低 z-order

        onClicked: {
            showFileDetails(filename)  // 显示详情面板
        }
    }

    // 信息区域悬停反馈
    Rectangle {
        anchors.fill: parent
        color: Style.accent
        opacity: infoArea.containsMouse ? 0.1 : 0
        z: -1

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    // ========== 操作按钮（右上角）==========
    Rectangle {
        id: printButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        width: 80
        height: 40
        color: Style.success
        radius: 4
        z: 10  // 高 z-order - 优先拦截点击

        Label {
            text: "打印"
            anchors.centerIn: parent
            color: "#FFFFFF"
        }

        MouseArea {
            id: actionArea
            anchors.fill: parent
            hoverEnabled: true
            z: 11

            onClicked: {
                printer.startPrint(filename)  // 开始打印
                mouse.accepted = true  // 阻止事件传播
            }
        }

        // 操作按钮悬停反馈
        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"
            opacity: actionArea.containsMouse ? 0.2 : 0
            z: -1
        }
    }
}
```

**触摸最佳实践**：
- ✅ 最小触摸目标：44x44 dp（11mm 物理尺寸）
- ✅ 操作按钮使用更高的 z-order 优先拦截点击
- ✅ 信息区域使用低 z-order 作为后备
- ✅ 分别提供悬停反馈以明确点击意图

### 状态视觉反馈 (State Visual Feedback)

#### 决策：QML State 对象 + Transition 动画

```qml
Rectangle {
    id: printerStatusWidget
    width: 200
    height: 100

    // 状态由 Python 属性驱动
    state: {
        if (printer.printerState === "error") return "error"
        if (printer.printerState === "printing") return "active"
        if (printer.isConnected) return "updating"
        return "idle"
    }

    // 状态定义
    states: [
        State {
            name: "idle"
            PropertyChanges {
                target: statusIndicator
                color: Style.textDisabled
            }
            PropertyChanges {
                target: statusLabel
                text: "离线"
            }
        },

        State {
            name: "updating"
            PropertyChanges {
                target: statusIndicator
                color: Style.success
            }
            PropertyChanges {
                target: statusLabel
                text: "就绪"
            }
        },

        State {
            name: "active"
            PropertyChanges {
                target: statusIndicator
                color: Style.info
            }
            PropertyChanges {
                target: statusLabel
                text: "打印中"
            }
            PropertyChanges {
                target: pulseAnimation
                running: true  // 启动脉冲动画
            }
        },

        State {
            name: "error"
            PropertyChanges {
                target: statusIndicator
                color: Style.error
            }
            PropertyChanges {
                target: statusLabel
                text: "错误"
            }
            PropertyChanges {
                target: shakeAnimation
                running: true  // 启动抖动动画
            }
        }
    ]

    // 状态间平滑过渡
    transitions: [
        Transition {
            from: "*"
            to: "*"

            ColorAnimation {
                target: statusIndicator
                property: "color"
                duration: Style.durationNormal
                easing.type: Easing.InOutQuad
            }
        }
    ]

    // 视觉元素
    Rectangle {
        id: statusIndicator
        width: 16
        height: 16
        radius: 8
    }

    Label {
        id: statusLabel
    }

    // 脉冲动画（打印中状态）
    SequentialAnimation {
        id: pulseAnimation
        running: false
        loops: Animation.Infinite

        PropertyAnimation {
            target: statusIndicator
            property: "scale"
            from: 1.0; to: 1.3
            duration: 800
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: statusIndicator
            property: "scale"
            from: 1.3; to: 1.0
            duration: 800
            easing.type: Easing.InOutQuad
        }
    }

    // 抖动动画（错误状态）
    SequentialAnimation {
        id: shakeAnimation
        running: false
        loops: 3

        PropertyAnimation {
            target: statusIndicator
            property: "x"
            from: 0; to: -5
            duration: 50
        }
        PropertyAnimation {
            target: statusIndicator
            property: "x"
            from: -5; to: 5
            duration: 100
        }
        PropertyAnimation {
            target: statusIndicator
            property: "x"
            from: 5; to: 0
            duration: 50
        }
    }
}
```

---

## 3. Metro 设计风格实现

### 决策 (Decision)

采用 **内容优先的 Metro 设计 + 机场标识美学**。

**关键原则**：
- ✅ 深色背景（`#000000`）+ 高对比度黄色强调色（`#FFEB3B`）
- ✅ 排版驱动的层级：大字号数字（`baseUnit * 4.5`）用于关键数据
- ✅ 最小装饰：微小圆角（2-4px）或无圆角，无阴影的扁平设计
- ✅ 内容先于界面：1920x440 超宽布局最大化信息密度
- ✅ 触摸优先：80px 导航按钮，60px 最小触摸目标
- ❌ 不使用边缘滑动手势

### 理由 (Rationale)

1. **信息密度优先**: Metro 的"真实数字化"设计理念适合 3D 打印机控制
2. **排版即界面**: 大字号数字（温度、进度）确保从远处可读
3. **诚实的材质**: 按钮看起来像可点击的矩形，而非物理按钮（无拟物化）
4. **基于网格的精确性**: 8px/12px 间距系统（`baseUnit`）保持视觉节奏

### 当前实现分析

项目的 `/home/tope/project_py/QtKs/qml/Style.qml` 已经展示了优秀的 Metro 设计基础：

```qml
QtObject {
    // ✅ 机场标识配色
    readonly property color bgPrimary: "#000000"
    readonly property color accent: "#FFEB3B"

    // ✅ 排版层级
    readonly property int fontSizeNormal: baseUnit * 1.2
    readonly property int fontSizeLarge: baseUnit * 1.8
    readonly property int fontSizeXLarge: baseUnit * 2.4

    // ✅ 最小圆角
    readonly property real radiusSmall: 4
    readonly property real radiusNormal: 6

    // ✅ 动画时长
    readonly property int durationFast: 150
    readonly property int durationNormal: 250

    // ✅ 间距系统
    readonly property real spacingXSmall: baseUnit * 0.3
    readonly property real spacingSmall: baseUnit * 0.6
    readonly property real spacingNormal: baseUnit * 1
    readonly property real spacingMedium: baseUnit * 1.5  // 12px - Metro 标准
    readonly property real spacingLarge: baseUnit * 2
}
```

### 需要增强的地方

#### 1. 触摸反馈（涟漪效果）

为主要按钮添加 Metro 2.0 涟漪效果：

```qml
// 添加到 MetroButton.qml
Rectangle {
    id: ripple
    anchors.centerIn: parent
    width: 0
    height: width
    radius: width / 2
    color: Style.textPrimary
    opacity: 0

    SequentialAnimation {
        id: rippleAnim
        PropertyAnimation {
            target: ripple
            properties: "width,opacity"
            to: parent.width * 1.5
            from: 0
            duration: 400
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: ripple
            property: "opacity"
            to: 0
            duration: 200
        }
    }
}

MouseArea {
    onPressed: rippleAnim.start()
}
```

#### 2. 页面转场动画

为 StackView 添加 Metro 风格页面转场：

```qml
StackView {
    pushEnter: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 0; to: 1
            duration: Style.durationNormal  // 250ms
            easing.type: Easing.OutCubic    // Metro 减速曲线
        }
    }

    pushExit: Transition {
        PropertyAnimation {
            property: "opacity"
            from: 1; to: 0
            duration: Style.durationFast  // 150ms
        }
    }
}
```

#### 3. 平滑数字动画

温度显示添加平滑变化动画：

```qml
// TempDisplay.qml
Label {
    property real displayTemp: 0  // 内部动画属性

    text: displayTemp.toFixed(1) + "°C"

    Behavior on displayTemp {
        SmoothedAnimation {
            velocity: 50  // 50°/秒最大变化速度
            duration: 1000
        }
    }

    // 绑定到后端数据
    Binding {
        target: tempLabel
        property: "displayTemp"
        value: printer.extruderTemp
    }
}
```

#### 4. Metro 加载指示器

将圆形 BusyIndicator 替换为 Metro 点阵风格：

```qml
Row {
    spacing: 8
    Repeater {
        model: 3
        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: Style.accent

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PropertyAnimation {
                    to: 0.3
                    duration: 400
                }
                PropertyAnimation {
                    to: 1.0
                    duration: 400
                }
                PauseAnimation { duration: index * 200 }  // 错开动画
            }
        }
    }
}
```

### Metro 网格布局（主页）

针对 1920x440 超宽屏的横向布局：

```qml
RowLayout {
    anchors.fill: parent
    spacing: Style.spacingMedium  // 12px Metro 网格

    // 左侧 60%：Widget 区域
    Rectangle {
        Layout.preferredWidth: parent.width * 0.6
        Layout.fillHeight: true

        // Widget 网格（2行3列）
        GridLayout {
            columns: 3
            rows: 2
            rowSpacing: Style.spacingMedium
            columnSpacing: Style.spacingMedium

            // 温度 Widget (1x1)
            TempWidget {
                Layout.preferredWidth: 300
                Layout.preferredHeight: 150
            }

            // 打印控制 Widget (2x2 - 跨行)
            PrintControlWidget {
                Layout.columnSpan: 2
                Layout.rowSpan: 2
                Layout.preferredWidth: 620
                Layout.preferredHeight: 312
            }
        }
    }

    // 右侧 40%：功能图标区域
    Rectangle {
        Layout.preferredWidth: parent.width * 0.4
        Layout.fillHeight: true

        // 稀疏图标网格（类似 iOS）
        GridLayout {
            columns: 3
            rows: 2
            rowSpacing: 20
            columnSpacing: 20

            Repeater {
                model: ["设置", "控制", "文件", "AFC", "移动", "更多"]

                FunctionIcon {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120
                    iconName: modelData
                }
            }
        }
    }
}
```

### 视觉反馈模式

#### 按钮状态（已实现 - 保持）

```qml
// MetroButton.qml - 当前实现优秀
states: State {
    name: "pressed"
    when: mouseArea.pressed && enabled
    PropertyChanges { target: button; scale: 0.98 }
}

Behavior on scale {
    NumberAnimation { duration: 100 }  // ✅ 快速触觉反馈
}
```

#### 悬停状态（已实现 - 保持）

```qml
Rectangle {
    anchors.fill: parent
    color: Style.textPrimary
    opacity: 0

    states: State {
        name: "hovered"
        when: mouseArea.containsMouse && enabled
        PropertyChanges { target: parent.children[1]; opacity: 0.1 }
    }

    Behavior on opacity {
        NumberAnimation { duration: Style.durationFast }
    }
}
```

#### 活动状态边框（导航按钮）

```qml
// NavigationButton.qml - 当前实现优秀
Rectangle {
    id: activeIndicator
    anchors.top: parent.top
    height: 4
    color: Style.accent
    visible: isCurrentPage
}
```

### 设计令牌维护

```qml
// Style.qml - 核心 Metro 值
QtObject {
    // ✅ 保持现有值
    readonly property real radiusSmall: 4          // Metro 微圆角
    readonly property int durationFast: 150        // 快速动画
    readonly property int durationNormal: 250      // 标准动画
    readonly property real spacingMedium: 12-13px  // Metro 网格间距
    readonly property int buttonHeightLarge: 100   // 主要操作

    // ⚠️ 建议调整
    readonly property int buttonHeight: baseUnit * 5  // 从 4.5 增加到 5（至少 60px）
}
```

### 性能目标

| 指标 | 目标 | 实现方式 |
|------|------|----------|
| UI 交互响应 | < 200ms | 立即反馈（缩放、不透明度） |
| 导航切换 | < 300ms | StackView 转场时长 250ms |
| Widget 更新 | < 500ms | 节流 + SmoothedAnimation |
| 帧率 | 60 FPS | 避免复杂嵌套、使用 GPU 加速 |

---

## 研究结论与实现优先级

### ✅ 已经优秀（保持现状）

1. 配色方案（机场标识美学）
2. 排版层级（大号等宽数字）
3. 导航按钮触摸目标（80px）
4. 悬停反馈（0.1 不透明度覆盖）
5. 最小圆角（2-4px）
6. 超宽屏横向布局

### 🔧 建议增强（按优先级）

#### 高优先级
1. **StackView 导航**：实现 StackView + 固定全局按钮
2. **Widget 数据绑定**：实现 @Property + notify 信号模式
3. **页面转场动画**：为 StackView 添加淡入淡出效果
4. **触摸涟漪动画**：为主要按钮添加涟漪反馈
5. **最小按钮高度**：将 `buttonHeight` 增加到 60px（`baseUnit * 5`）

#### 中优先级
6. **平滑数字动画**：温度显示使用 SmoothedAnimation
7. **非模态弹出层**：温度输入键盘使用 Popup 包装
8. **Metro 加载指示器**：将圆形 BusyIndicator 替换为点阵风格
9. **状态驱动 UI**：Widget 使用 QML State 对象管理状态
10. **错误闪烁反馈**：操作失败时的视觉反馈

#### 低优先级
11. **网格瓷砖系统**：未来 Widget 仪表板的网格布局
12. **错开列表动画**：如果添加可滚动列表

---

## 技术决策总结表

| 领域 | 决策 | 理由 | 状态 |
|------|------|------|------|
| **导航** | StackView + 固定按钮 | 内置栈管理、生命周期、无手势冲突 | ⚠️ 待实现 |
| **数据绑定** | @Property + notify 信号 | 单向数据流、自动更新、线程安全 | ✅ 已部分实现 |
| **WebSocket** | QThread + Signal | 隔离阻塞 I/O、跨线程安全 | ✅ 已实现 |
| **覆盖层** | 非模态 Popup + dim | 背景继续更新、触摸友好 | ⚠️ 待实现 |
| **点击区域** | 分离 MouseArea + z-order | 明确交互意图、触摸友好 | ⚠️ 待实现 |
| **状态反馈** | QML State + Transition | 声明式、自动动画 | ⚠️ 待实现 |
| **设计风格** | Metro + 机场标识 | 信息密度、触摸优先、诚实材质 | ✅ 已实现 |
| **动画** | OutCubic + 150-250ms | Metro 减速曲线、快速响应 | ⚠️ 部分实现 |
| **节流** | 0.5°C / 1s 间隔 | 减少无意义更新、性能优化 | ✅ 已实现 |

---

## 下一步行动

基于本研究，Phase 1（设计与契约）将生成：

1. **data-model.md**: 数据实体定义（Widget 类型、导航状态、页面元数据）
2. **contracts/qml-python-api.md**: QML-Python 接口契约（@Property、@Slot、Signal 定义）
3. **contracts/navigation-api.md**: 导航系统 API（StackView 操作、页面生命周期）
4. **contracts/widget-api.md**: Widget 交互 API（数据绑定、状态管理、事件处理）
5. **quickstart.md**: 快速入门指南（开发者文档）

**关键要解决的未知项**：
- ✅ 测试框架：需确认使用 pytest（Python）+ QML Test（QML）
- ✅ 导航模式：已确认使用 StackView + 固定按钮
- ✅ Widget 数据流：已确认使用 @Property + notify 信号
- ✅ Metro 设计实现：已确认增强方向

**所有 NEEDS CLARIFICATION 项已解决。**
