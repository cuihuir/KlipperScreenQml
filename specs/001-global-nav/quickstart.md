# 快速入门：iOS 风格全局导航与主页设计

**功能分支**: `001-global-nav`
**创建日期**: 2025-11-27
**目标受众**: 开发者

## 概述

本指南帮助开发者快速理解和实现 iOS 风格全局导航系统和主页设计。阅读本文档后，你将能够：

1. 设置 StackView 导航系统
2. 创建主页 Widget
3. 实现全局导航按钮
4. 添加新功能页面

**预计阅读时间**: 15 分钟

---

## 前置要求

- Python 3.10+
- PySide6 >= 6.5.0
- QML 基础知识
- 已克隆 QtKs 项目仓库

---

## 快速开始（5 分钟）

### 1. 检出功能分支

```bash
cd /home/tope/project_py/QtKs
git checkout 001-global-nav
```

### 2. 创建导航管理器

```bash
# 创建 Python 后端文件
touch backend/navigation_manager.py
```

```python
# backend/navigation_manager.py
from PySide6.QtCore import QObject, Signal, Slot, Property

class NavigationManager(QObject):
    navigationChanged = Signal(str, int)
    depthChanged = Signal(int)
    currentPageChanged = Signal(str)
    canGoBackChanged = Signal(bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._navigation_stack = ["home"]
        self._current_page = "home"
        self._can_go_back = False

    @Property(int, notify=depthChanged)
    def currentDepth(self):
        return len(self._navigation_stack)

    @Property(str, notify=currentPageChanged)
    def currentPage(self):
        return self._current_page

    @Property(bool, notify=canGoBackChanged)
    def canGoBack(self):
        return self._can_go_back

    @Slot(str)
    def pushPage(self, page_id: str):
        self._navigation_stack.append(page_id)
        self._current_page = page_id
        self._can_go_back = len(self._navigation_stack) > 1
        self.navigationChanged.emit(page_id, len(self._navigation_stack))
        self.currentPageChanged.emit(page_id)
        self.depthChanged.emit(len(self._navigation_stack))
        self.canGoBackChanged.emit(self._can_go_back)

    @Slot()
    def popPage(self):
        if len(self._navigation_stack) <= 1:
            return
        self._navigation_stack.pop()
        self._current_page = self._navigation_stack[-1]
        self._can_go_back = len(self._navigation_stack) > 1
        self.navigationChanged.emit(self._current_page, len(self._navigation_stack))
        self.currentPageChanged.emit(self._current_page)
        self.depthChanged.emit(len(self._navigation_stack))
        self.canGoBackChanged.emit(self._can_go_back)

    @Slot()
    def popToRoot(self):
        if len(self._navigation_stack) == 1:
            return
        self._navigation_stack = ["home"]
        self._current_page = "home"
        self._can_go_back = False
        self.navigationChanged.emit("home", 1)
        self.currentPageChanged.emit("home")
        self.depthChanged.emit(1)
        self.canGoBackChanged.emit(False)
```

### 3. 注册到主应用

```python
# backend/application.py（添加到现有代码）
from backend.navigation_manager import NavigationManager

class Application(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        # ... 现有代码 ...

        # 新增：导航管理器
        self.navigation_manager = NavigationManager(parent=self)

    @Property(QObject, constant=True)
    def navigationManager(self):
        return self.navigation_manager
```

### 4. 创建全局导航按钮

```bash
touch qml/components/GlobalNavButtons.qml
```

```qml
// qml/components/GlobalNavButtons.qml
import QtQuick
import QtQuick.Controls

Column {
    id: root
    width: 80
    spacing: 20
    padding: 20

    property var navigationManager: app.navigationManager
    property var stackView: null

    Button {
        text: "HOME"
        width: parent.width - parent.padding * 2
        height: 80
        enabled: true

        onClicked: {
            if (stackView) {
                stackView.pop(null)
            }
            navigationManager.popToRoot()
        }
    }

    Button {
        text: "RETURN"
        width: parent.width - parent.padding * 2
        height: 80
        enabled: navigationManager.canGoBack

        onClicked: {
            if (stackView) {
                stackView.pop()
            }
            navigationManager.popPage()
        }
    }
}
```

### 5. 更新 MainWindow

```qml
// qml/MainWindow.qml（简化示例）
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1920
    height: 440

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 全局按钮
        GlobalNavButtons {
            id: globalNav
            Layout.preferredWidth: 80
            Layout.fillHeight: true
            stackView: stackView
            z: 100
        }

        // StackView
        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            initialItem: Component {
                HomePage {}
            }

            pushEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: 250
                }
            }
        }
    }
}
```

### 6. 运行应用

```bash
python3 main.py
```

✅ 你现在应该看到带有 HOME/RETURN 按钮的主窗口！

---

## 核心概念

### 1. 导航栈

```
深度 1: [HomePage]               ← 根页面
深度 2: [HomePage, SettingsPage] ← 进入设置
深度 3: [HomePage, SettingsPage, NetworkPage] ← 进入网络设置
```

- **pushPage()**: 推送新页面（深度 +1）
- **popPage()**: 返回上一级（深度 -1）
- **popToRoot()**: 返回主页（深度 = 1）

### 2. 页面生命周期

```
创建 → onActivating → 动画 → onActivated → (用户交互) →
     → onDeactivating → 动画 → onDeactivated → onRemoved → 销毁
```

### 3. Widget 状态

```
idle → active → updating → (成功/失败) → idle/error
```

---

## 常见任务

### 添加新功能页面

**步骤 1**: 创建 QML 页面

```bash
touch qml/pages/MyNewPage.qml
```

```qml
// qml/pages/MyNewPage.qml
import QtQuick
import QtQuick.Controls

Page {
    id: myPage

    property StackView stackView: StackView.view

    StackView.onActivated: {
        console.log("MyNewPage activated")
    }

    Label {
        anchors.centerIn: parent
        text: "我的新页面"
        font.pixelSize: 24
    }
}
```

**步骤 2**: 注册到页面注册表

```qml
// qml/MainWindow.qml
QtObject {
    id: pageRegistry

    property var pages: ({
        "settings": settingsComponent,
        "myNew": myNewComponent  // 新增
    })

    Component { id: settingsComponent; SettingsPage {} }
    Component { id: myNewComponent; MyNewPage {} }  // 新增

    function navigateTo(pageId, properties) {
        var component = pages[pageId]
        if (component) {
            stackView.push(component, properties || {})
            navigationManager.pushPage(pageId)
            return true
        }
        return false
    }
}
```

**步骤 3**: 从主页导航

```qml
// qml/pages/HomePage.qml
Button {
    text: "打开我的新页面"
    onClicked: {
        pageRegistry.navigateTo("myNew")
    }
}
```

### 添加新 Widget

**步骤 1**: 创建 Widget 组件

```bash
touch qml/components/MyWidget.qml
```

```qml
// qml/components/MyWidget.qml
import QtQuick
import QtQuick.Controls

HomeWidget {
    id: myWidget

    widgetId: "my_widget"
    title: "我的 Widget"

    // 自定义属性
    property string data: "Hello"

    // 数据绑定
    Connections {
        target: printer
        function onMyDataChanged(newData) {
            myWidget.data = newData
        }
    }

    // UI
    Column {
        anchors.centerIn: parent
        spacing: 10

        Label {
            text: title
            font.pixelSize: 16
        }

        Label {
            text: data
            font.pixelSize: 24
        }
    }

    // 交互
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("Widget clicked")
        }
    }
}
```

**步骤 2**: 添加到主页

```qml
// qml/pages/HomePage.qml
GridLayout {
    TempWidget { heaterName: "extruder" }
    FanWidget { fanName: "fan" }
    MyWidget {}  // 新增
}
```

---

## 调试技巧

### 1. 查看导航栈

```qml
Button {
    text: "Debug"
    onClicked: {
        console.log("当前深度:", navigationManager.currentDepth)
        console.log("当前页面:", navigationManager.currentPage)
        console.log("可否返回:", navigationManager.canGoBack)
    }
}
```

### 2. 监听导航事件

```qml
Connections {
    target: navigationManager
    function onNavigationChanged(pageId, depth) {
        console.log("导航到:", pageId, "深度:", depth)
    }
}
```

### 3. 监听生命周期

```qml
Page {
    StackView.onActivating: { console.log("onActivating") }
    StackView.onActivated: { console.log("onActivated") }
    StackView.onDeactivating: { console.log("onDeactivating") }
    StackView.onDeactivated: { console.log("onDeactivated") }
    StackView.onRemoved: { console.log("onRemoved") }
}
```

---

## 性能优化建议

1. **使用 Component 动态加载页面**（避免预实例化所有页面）
2. **在 onDeactivated 中停止定时器**（节省 CPU）
3. **使用 SmoothedAnimation 而非 NumberAnimation**（平滑数字变化）
4. **Widget 数据节流**（温度 >= 0.5°C，进度 >= 1s）

---

## 下一步

- 阅读 `data-model.md` 了解完整数据结构
- 阅读 `contracts/` 了解 API 契约
- 查看 `research.md` 了解设计决策
- 运行 `/speckit.tasks` 生成任务列表
- 运行 `/speckit.implement` 开始实现

---

## 常见问题

**Q: Return 按钮不可点击？**

A: 检查 `navigationManager.canGoBack` 是否为 `true`。只有在 `depth > 1` 时才启用。

**Q: 页面导航后白屏？**

A: 检查页面组件是否正确注册到 `pageRegistry.pages`。

**Q: Widget 数据不更新？**

A: 确认 `Connections { target: printer }` 正确连接，且信号名称匹配。

**Q: 动画卡顿？**

A: 减少转场动画时长（150-250ms），避免复杂嵌套布局。

---

## 参考文档

- [data-model.md](./data-model.md) - 数据模型定义
- [contracts/qml-python-api.md](./contracts/qml-python-api.md) - QML-Python 接口
- [contracts/navigation-api.md](./contracts/navigation-api.md) - 导航系统 API
- [contracts/widget-api.md](./contracts/widget-api.md) - Widget 交互 API
- [research.md](./research.md) - 技术研究报告
- [PySide6 文档](https://doc.qt.io/qtforpython-6/)
- [QML 文档](https://doc.qt.io/qt-6/qmlapplications.html)
