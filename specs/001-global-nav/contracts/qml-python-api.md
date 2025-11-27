# QML-Python API 契约

**功能分支**: `001-global-nav`
**创建日期**: 2025-11-27
**版本**: 1.0.0

## 概述

本文档定义 QML 前端与 Python 后端之间的接口契约，包括属性暴露、方法调用和信号发射的规范。

---

## 契约原则

1. **单向数据流**: Python → QML 使用只读 `@Property` + `notify` 信号
2. **命令模式**: QML → Python 使用 `@Slot` 装饰器方法
3. **线程安全**: 所有信号发射在主线程执行（Qt 自动处理）
4. **节流优化**: Python 端实现数据节流，减少无意义更新

---

## 1. NavigationManager API

### Python 实现契约

```python
# backend/navigation_manager.py

from PySide6.QtCore import QObject, Signal, Slot, Property

class NavigationManager(QObject):
    """导航管理器 - 管理页面栈和历史"""

    # ===== 信号定义 =====
    navigationChanged = Signal(str, int)  # (page_id, depth)
    depthChanged = Signal(int)            # depth
    currentPageChanged = Signal(str)      # page_id
    canGoBackChanged = Signal(bool)       # canGoBack

    def __init__(self, parent=None):
        super().__init__(parent)
        self._navigation_stack = ["home"]  # 初始栈：主页
        self._current_page = "home"
        self._can_go_back = False

    # ===== 只读属性（QML 绑定） =====

    @Property(int, notify=depthChanged)
    def currentDepth(self):
        """当前导航栈深度"""
        return len(self._navigation_stack)

    @Property(str, notify=currentPageChanged)
    def currentPage(self):
        """当前页面 ID"""
        return self._current_page

    @Property(bool, notify=canGoBackChanged)
    def canGoBack(self):
        """是否可以返回上一级"""
        return self._can_go_back

    # ===== QML 调用的方法 =====

    @Slot(str)
    def pushPage(self, page_id: str):
        """推送新页面到导航栈"""
        if not page_id:
            return

        self._navigation_stack.append(page_id)
        self._current_page = page_id
        self._can_go_back = len(self._navigation_stack) > 1

        # 发射信号通知 QML 更新
        self.navigationChanged.emit(page_id, len(self._navigation_stack))
        self.currentPageChanged.emit(page_id)
        self.depthChanged.emit(len(self._navigation_stack))
        self.canGoBackChanged.emit(self._can_go_back)

    @Slot()
    def popPage(self):
        """弹出当前页面，返回上一级"""
        if len(self._navigation_stack) <= 1:
            return  # 不能弹出主页

        self._navigation_stack.pop()
        self._current_page = self._navigation_stack[-1]
        self._can_go_back = len(self._navigation_stack) > 1

        # 发射信号
        self.navigationChanged.emit(self._current_page, len(self._navigation_stack))
        self.currentPageChanged.emit(self._current_page)
        self.depthChanged.emit(len(self._navigation_stack))
        self.canGoBackChanged.emit(self._can_go_back)

    @Slot()
    def popToRoot(self):
        """弹出所有页面，返回主页"""
        if len(self._navigation_stack) == 1:
            return  # 已经在主页

        self._navigation_stack = ["home"]
        self._current_page = "home"
        self._can_go_back = False

        # 发射信号
        self.navigationChanged.emit("home", 1)
        self.currentPageChanged.emit("home")
        self.depthChanged.emit(1)
        self.canGoBackChanged.emit(False)

    @Slot(int)
    def popToDepth(self, depth: int):
        """弹出到指定深度"""
        if depth < 1 or depth >= len(self._navigation_stack):
            return

        self._navigation_stack = self._navigation_stack[:depth]
        self._current_page = self._navigation_stack[-1]
        self._can_go_back = len(self._navigation_stack) > 1

        # 发射信号
        self.navigationChanged.emit(self._current_page, depth)
        self.currentPageChanged.emit(self._current_page)
        self.depthChanged.emit(depth)
        self.canGoBackChanged.emit(self._can_go_back)
```

### QML 使用契约

```qml
// qml/MainWindow.qml

import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root

    // 1. 访问 NavigationManager（从 main.py 注册的 context property）
    property var navigationManager: app.navigationManager

    RowLayout {
        // 全局按钮
        Column {
            Button {
                text: "HOME"
                enabled: true  // HOME 始终启用
                onClicked: navigationManager.popToRoot()
            }

            Button {
                text: "RETURN"
                // ✅ 绑定到 canGoBack 属性（自动更新）
                enabled: navigationManager.canGoBack
                onClicked: navigationManager.popPage()
            }
        }

        // StackView
        StackView {
            id: stackView

            // 监听导航信号（如果需要）
            Connections {
                target: navigationManager
                function onNavigationChanged(pageId, depth) {
                    console.log("导航到:", pageId, "深度:", depth)
                }
            }
        }
    }
}
```

---

## 2. MoonrakerClient API（扩展）

### Python 实现契约

```python
# backend/moonraker_client.py（扩展现有代码）

class MoonrakerClient(QObject):
    """Moonraker 客户端 - 打印机数据源"""

    # ===== 新增信号 =====
    fanStateChanged = Signal(str, bool, float)  # (fan_name, isOn, speed)
    ledStateChanged = Signal(str, bool, float)  # (led_name, isOn, brightness)

    def __init__(self, host: str, port: int, parent=None):
        super().__init__(parent)
        # ... 现有代码 ...

        # 新增内部状态
        self._fan_states = {}   # {fan_name: {"on": bool, "speed": float}}
        self._led_states = {}   # {led_name: {"on": bool, "brightness": float}}

    # ===== 温度控制（已存在） =====

    @Slot(str, int)
    def setExtruderTemp(self, heater_name: str, target_temp: int):
        """设置加热器目标温度"""
        self._send_gcode(f"SET_HEATER_TEMPERATURE HEATER={heater_name} TARGET={target_temp}")

    # ===== 风扇控制（新增） =====

    @Slot(str, bool)
    def setFanOnOff(self, fan_name: str, on: bool):
        """开关风扇"""
        if on:
            self._send_gcode(f"SET_FAN_SPEED FAN={fan_name} SPEED=1.0")
        else:
            self._send_gcode(f"SET_FAN_SPEED FAN={fan_name} SPEED=0")

    @Slot(str, float)
    def setFanSpeed(self, fan_name: str, speed: float):
        """设置风扇速度（0.0-1.0）"""
        speed = max(0.0, min(1.0, speed))  # 钳制到有效范围
        self._send_gcode(f"SET_FAN_SPEED FAN={fan_name} SPEED={speed}")

    # ===== LED 控制（新增） =====

    @Slot(str, bool)
    def setLedOnOff(self, led_name: str, on: bool):
        """开关 LED"""
        if on:
            self._send_gcode(f"SET_LED LED={led_name} RED=1 GREEN=1 BLUE=1")
        else:
            self._send_gcode(f"SET_LED LED={led_name} RED=0 GREEN=0 BLUE=0")

    @Slot(str, float)
    def setLedBrightness(self, led_name: str, brightness: float):
        """设置 LED 亮度（0.0-1.0）"""
        brightness = max(0.0, min(1.0, brightness))
        self._send_gcode(f"SET_LED LED={led_name} RED={brightness} GREEN={brightness} BLUE={brightness}")

    # ===== 打印控制（已存在 - 扩展） =====

    @Slot(str)
    def startPrint(self, filename: str):
        """开始打印"""
        self._send_gcode(f"SDCARD_PRINT_FILE FILENAME=\"{filename}\"")

    @Slot()
    def pausePrint(self):
        """暂停打印"""
        self._send_gcode("PAUSE")

    @Slot()
    def resumePrint(self):
        """继续打印"""
        self._send_gcode("RESUME")

    @Slot()
    def cancelPrint(self):
        """取消打印"""
        self._send_gcode("CANCEL_PRINT")

    # ===== 属性访问器（新增） =====

    def getFanState(self, fan_name: str) -> dict:
        """获取风扇状态"""
        return self._fan_states.get(fan_name, {"on": False, "speed": 0.0})

    def getLedState(self, led_name: str) -> dict:
        """获取 LED 状态"""
        return self._led_states.get(led_name, {"on": False, "brightness": 0.0})

    # ===== 内部更新方法（扩展） =====

    def _update_from_status(self, status: dict):
        """解析 WebSocket 状态更新"""
        # ... 现有温度/进度更新代码 ...

        # 更新风扇状态
        if 'fan' in status:
            for fan_name, fan_data in status['fan'].items():
                speed = fan_data.get('speed', 0.0)
                is_on = speed > 0.01
                if fan_name not in self._fan_states or \
                   self._fan_states[fan_name]["speed"] != speed:
                    self._fan_states[fan_name] = {"on": is_on, "speed": speed}
                    self.fanStateChanged.emit(fan_name, is_on, speed)

        # 更新 LED 状态
        if 'led' in status:
            for led_name, led_data in status['led'].items():
                brightness = led_data.get('value', 0.0)
                is_on = brightness > 0.01
                if led_name not in self._led_states or \
                   self._led_states[led_name]["brightness"] != brightness:
                    self._led_states[led_name] = {"on": is_on, "brightness": brightness}
                    self.ledStateChanged.emit(led_name, is_on, brightness)
```

### QML 使用契约

```qml
// qml/components/FanWidget.qml

import QtQuick
import QtQuick.Controls

Rectangle {
    id: fanWidget

    property string fanName: "fan"  // 风扇名称
    property bool isOn: false       // 绑定到 Python
    property real speed: 0.0        // 绑定到 Python

    // 监听后端风扇状态变化
    Connections {
        target: printer  // MoonrakerClient 实例
        function onFanStateChanged(name, on, spd) {
            if (name === fanWidget.fanName) {
                fanWidget.isOn = on
                fanWidget.speed = spd
            }
        }
    }

    Column {
        Label {
            text: "风扇: " + (isOn ? "开启" : "关闭")
        }

        Label {
            text: "速度: " + Math.round(speed * 100) + "%"
        }

        Slider {
            from: 0.0
            to: 1.0
            value: speed

            onValueChanged: {
                if (pressed) {
                    // 用户拖动时调用后端方法
                    printer.setFanSpeed(fanWidget.fanName, value)
                }
            }
        }

        Button {
            text: isOn ? "关闭" : "开启"
            onClicked: {
                printer.setFanOnOff(fanWidget.fanName, !isOn)
            }
        }
    }
}
```

---

## 3. Application API（主应用）

### Python 实现契约

```python
# backend/application.py（扩展现有代码）

class Application(QObject):
    """主应用控制器"""

    def __init__(self, parent=None):
        super().__init__(parent)

        # 现有组件
        self.config = ConfigManager()
        self.moonraker = MoonrakerClient(...)
        self.ui_state = UIState(parent=self)

        # ✅ 新增：导航管理器
        self.navigation_manager = NavigationManager(parent=self)

    # ===== 暴露给 QML 的对象属性 =====

    @Property(QObject, constant=True)
    def printer(self):
        """返回打印机客户端"""
        return self.moonraker

    @Property(QObject, constant=True)
    def uiState(self):
        """返回 UI 状态管理器"""
        return self.ui_state

    @Property(QObject, constant=True)
    def navigationManager(self):
        """返回导航管理器（新增）"""
        return self.navigation_manager
```

### main.py 注册契约

```python
# main.py

from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication
from backend.application import Application

if __name__ == "__main__":
    qapp = QApplication(sys.argv)

    # 创建应用实例
    app = Application()

    # 创建 QML 引擎
    engine = QQmlApplicationEngine()

    # ✅ 注册为全局上下文属性
    engine.rootContext().setContextProperty("app", app)
    engine.rootContext().setContextProperty("printer", app.printer)
    engine.rootContext().setContextProperty("navigationManager", app.navigationManager)

    # 加载 QML
    engine.load("qml/MainWindow.qml")

    sys.exit(qapp.exec())
```

---

## 4. 信号与槽命名约定

### 信号命名规范

| 模式 | 示例 | 用途 |
|------|------|------|
| `{property}Changed` | `temperatureChanged`, `progressChanged` | 属性值变化 |
| `{action}Completed` | `printCompleted`, `downloadCompleted` | 操作完成 |
| `{entity}Updated` | `statusUpdated`, `fileListUpdated` | 批量更新 |
| `{entity}Error` | `connectionError`, `printError` | 错误事件 |

### 槽方法命名规范

| 模式 | 示例 | 用途 |
|------|------|------|
| `set{Property}` | `setExtruderTemp`, `setFanSpeed` | 设置属性 |
| `{action}{Entity}` | `startPrint`, `pausePrint`, `cancelPrint` | 执行操作 |
| `get{Entity}` | `getFileList`, `getMetadata` | 查询数据 |

---

## 5. 类型映射表

### Python ↔ QML 类型对应

| Python 类型 | QML 类型 | 注释 |
|------------|---------|------|
| `int` | `int` | 整数 |
| `float` | `real` | 浮点数 |
| `str` | `string` | 字符串 |
| `bool` | `bool` | 布尔值 |
| `list` | `var` (Array) | 列表 → JS 数组 |
| `dict` | `var` (Object) | 字典 → JS 对象 |
| `QObject` | `QtObject` / `Item` | Qt 对象 |
| `None` | `null` / `undefined` | 空值 |

### 信号参数类型示例

```python
# Python 信号定义
temperatureChanged = Signal(float, float)    # (current, target)
printStateChanged = Signal(str)              # state
layerChanged = Signal(int, int)              # (current, total)
statusUpdated = Signal(dict)                 # status_data
```

```qml
// QML 信号处理
Connections {
    target: printer
    function onTemperatureChanged(current, target) {
        // current: real, target: real
    }
    function onPrintStateChanged(state) {
        // state: string
    }
    function onLayerChanged(current, total) {
        // current: int, total: int
    }
    function onStatusUpdated(statusData) {
        // statusData: var (Object)
        console.log(statusData.extruder_temp)
    }
}
```

---

## 6. 错误处理契约

### Python 端错误处理

```python
@Slot(str, int)
def setExtruderTemp(self, heater_name: str, target_temp: int):
    """设置加热器目标温度"""
    try:
        # 验证输入
        if not heater_name:
            raise ValueError("Heater name cannot be empty")
        if target_temp < 0 or target_temp > 300:
            raise ValueError(f"Invalid temperature: {target_temp}")

        # 执行操作
        self._send_gcode(f"SET_HEATER_TEMPERATURE HEATER={heater_name} TARGET={target_temp}")

    except ValueError as e:
        # 发射错误信号
        self.commandError.emit(f"设置温度失败: {str(e)}")
    except Exception as e:
        self.commandError.emit(f"未知错误: {str(e)}")
```

### QML 端错误处理

```qml
// QML 错误监听
Connections {
    target: printer
    function onCommandError(message) {
        errorDialog.text = message
        errorDialog.open()
    }
}

Dialog {
    id: errorDialog
    title: "操作失败"
    property alias text: errorLabel.text

    Label {
        id: errorLabel
    }

    standardButtons: Dialog.Ok
}
```

---

## 7. 性能契约

### 节流策略

| 数据类型 | 最小更新间隔 | 实现位置 |
|---------|------------|----------|
| 温度 | 0.5°C 或 500ms | `_update_from_status()` |
| 打印进度 | 1.0s | `_update_from_status()` |
| 风扇速度 | 0.05 (5%) 或 1s | `_update_from_status()` |
| 图层 | 值变化时 | `_update_from_status()` |

### 批量更新

对于多个相关属性，使用单个信号携带字典：

```python
# ❌ 不推荐：多个信号
self.extruderTempChanged.emit(temp)
self.bedTempChanged.emit(temp)
self.chamberTempChanged.emit(temp)

# ✅ 推荐：单个批量信号
self.temperatureUpdated.emit({
    'extruder': 210.0,
    'bed': 60.0,
    'chamber': 40.0
})
```

---

## 8. 测试契约

### Python 单元测试

```python
# tests/test_navigation_manager.py

import pytest
from backend.navigation_manager import NavigationManager

def test_push_page():
    nav = NavigationManager()
    assert nav.currentDepth == 1
    assert nav.currentPage == "home"

    nav.pushPage("settings")
    assert nav.currentDepth == 2
    assert nav.currentPage == "settings"
    assert nav.canGoBack == True

def test_pop_page():
    nav = NavigationManager()
    nav.pushPage("settings")
    nav.pushPage("network")

    nav.popPage()
    assert nav.currentDepth == 2
    assert nav.currentPage == "settings"

def test_pop_to_root():
    nav = NavigationManager()
    nav.pushPage("settings")
    nav.pushPage("network")
    nav.pushPage("wifi")

    nav.popToRoot()
    assert nav.currentDepth == 1
    assert nav.currentPage == "home"
    assert nav.canGoBack == False
```

### QML 测试（示例）

```qml
// tests/tst_navigation.qml

import QtTest 1.0
import QtQuick 2.0

TestCase {
    name: "NavigationTests"

    property var navigationManager: NavigationManager {}

    function test_push_page() {
        compare(navigationManager.currentDepth, 1)
        compare(navigationManager.currentPage, "home")

        navigationManager.pushPage("settings")
        compare(navigationManager.currentDepth, 2)
        compare(navigationManager.canGoBack, true)
    }

    function test_pop_to_root() {
        navigationManager.pushPage("settings")
        navigationManager.pushPage("network")

        navigationManager.popToRoot()
        compare(navigationManager.currentDepth, 1)
        compare(navigationManager.currentPage, "home")
    }
}
```

---

## 总结

本契约定义了：
- ✅ Python 类的 `@Property`, `@Slot`, `Signal` 完整实现规范
- ✅ QML 端访问 Python 对象的方法
- ✅ 信号/槽命名约定
- ✅ 类型映射表
- ✅ 错误处理模式
- ✅ 性能优化契约（节流、批量更新）
- ✅ 测试示例

**下一步**: 生成 `navigation-api.md` 和 `widget-api.md` 契约文档。
