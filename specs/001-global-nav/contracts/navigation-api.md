# 导航系统 API 契约

**功能分支**: `001-global-nav`
**创建日期**: 2025-11-27
**版本**: 1.0.0

## 概述

本文档定义 StackView 导航系统的 QML 实现规范，包括页面注册、导航操作、生命周期管理和转场动画。

---

## 1. StackView 配置

### 基础结构

```qml
// qml/MainWindow.qml

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

        // 全局导航按钮（固定）
        Rectangle {
            id: globalNavBar
            Layout.preferredWidth: 80
            Layout.fillHeight: true
            color: Style.bgSecondary
            z: 100

            Column {
                anchors.centerIn: parent
                spacing: Style.spacingLarge

                NavigationButton {
                    id: homeButton
                    iconSource: "qrc:/icons/home.svg"
                    tooltip: "主页"
                    enabled: true
                    onClicked: stackView.pop(null)  // 返回根页面
                }

                NavigationButton {
                    id: returnButton
                    iconSource: "qrc:/icons/back.svg"
                    tooltip: "返回"
                    enabled: stackView.depth > 1
                    onClicked: stackView.pop()
                }
            }
        }

        // 主内容区（StackView）
        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 初始页面：主页
            initialItem: homePageComponent

            // 转场动画配置
            pushEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Style.durationNormal  // 250ms
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    property: "x"
                    from: stackView.width * 0.1
                    to: 0
                    duration: Style.durationNormal
                    easing.type: Easing.OutCubic
                }
            }

            pushExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: Style.durationFast  // 150ms
                }
            }

            popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Style.durationNormal
                    easing.type: Easing.OutCubic
                }
            }

            popExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: Style.durationFast
                }
                PropertyAnimation {
                    property: "x"
                    from: 0
                    to: stackView.width * 0.1
                    duration: Style.durationFast
                    easing.type: Easing.InCubic
                }
            }

            replaceEnter: pushEnter
            replaceExit: pushExit
        }
    }

    // 页面组件定义
    Component {
        id: homePageComponent
        HomePage {}
    }
}
```

---

## 2. 页面注册表

### 标准页面映射

| 页面 ID | 页面名称 | QML 文件路径 | 初始化方式 |
|---------|---------|-------------|-----------|
| `home` | 主页 | `qml/pages/HomePage.qml` | 预实例化 (initialItem) |
| `settings` | 设置 | `qml/pages/SettingsPage.qml` | Component 动态加载 |
| `control` | 控制 | `qml/pages/ControlPage.qml` | Component 动态加载 |
| `files` | 文件 | `qml/pages/FilesPage.qml` | Component 动态加载 |
| `printing` | 打印详情 | `qml/pages/PrintingPage.qml` | Component 动态加载 |
| `afc` | AFC | `qml/pages/AfcPage.qml` | Component 动态加载 |
| `move` | 移动 | `qml/pages/MovePage.qml` | Component 动态加载 |

### 页面组件注册

```qml
// qml/MainWindow.qml

QtObject {
    id: pageRegistry

    // 页面组件字典
    readonly property var pages: ({
        "settings": settingsComponent,
        "control": controlComponent,
        "files": filesComponent,
        "printing": printingComponent,
        "afc": afcComponent,
        "move": moveComponent
    })

    Component { id: settingsComponent; SettingsPage {} }
    Component { id: controlComponent; ControlPage {} }
    Component { id: filesComponent; FilesPage {} }
    Component { id: printingComponent; PrintingPage {} }
    Component { id: afcComponent; AfcPage {} }
    Component { id: moveComponent; MovePage {} }

    // 导航辅助函数
    function navigateTo(pageId, properties) {
        var component = pages[pageId]
        if (!component) {
            console.error("未知页面:", pageId)
            return false
        }

        if (properties) {
            stackView.push(component, properties)
        } else {
            stackView.push(component)
        }

        // 更新 Python 端导航管理器
        navigationManager.pushPage(pageId)
        return true
    }
}
```

---

## 3. 页面生命周期 API

### Page 基类扩展

每个页面必须继承 `Page` 并实现生命周期钩子：

```qml
// qml/pages/SettingsPage.qml

import QtQuick
import QtQuick.Controls

Page {
    id: settingsPage

    // ===== 页面元数据 =====
    readonly property string pageId: "settings"
    readonly property string pageTitle: "设置"

    // ===== 访问 StackView =====
    property StackView stackView: StackView.view

    // ===== 生命周期钩子 =====

    // 页面正在激活（push 动画开始前）
    StackView.onActivating: {
        console.log("[Settings] Activating")
        // 预加载数据
        prepareData()
    }

    // 页面已激活（push 动画完成后）
    StackView.onActivated: {
        console.log("[Settings] Activated")
        // 启动定时器、动画
        startTimers()
    }

    // 页面正在停用（pop 动画开始前）
    StackView.onDeactivating: {
        console.log("[Settings] Deactivating")
        // 保存状态
        saveState()
    }

    // 页面已停用（pop 动画完成后）
    StackView.onDeactivated: {
        console.log("[Settings] Deactivated")
        // 停止定时器、动画
        stopTimers()
    }

    // 页面已从栈中移除（即将销毁）
    StackView.onRemoved: {
        console.log("[Settings] Removed")
        // 最终清理
        cleanup()
    }

    // 标准 QML 组件生命周期
    Component.onCompleted: {
        console.log("[Settings] Component created")
        initializeComponent()
    }

    Component.onDestruction: {
        console.log("[Settings] Component destroyed")
    }

    // ===== 生命周期辅助方法 =====

    function prepareData() {
        // 预加载配置数据
    }

    function startTimers() {
        // 启动定时刷新
    }

    function saveState() {
        // 保存当前配置
    }

    function stopTimers() {
        // 停止所有定时器
    }

    function cleanup() {
        // 释放资源
    }

    function initializeComponent() {
        // 组件初始化
    }
}
```

### 生命周期状态图

```
Component 创建
    ↓
Component.onCompleted
    ↓
StackView.onActivating  ←─┐
    ↓                     │
push 动画执行             │ 返回此页面
    ↓                     │
StackView.onActivated     │
    ↓                     │
（页面可见，用户交互）      │
    ↓                     │
StackView.onDeactivating  │
    ↓                     │
pop 动画执行              │
    ↓                     │
StackView.onDeactivated ──┘
    ↓
StackView.onRemoved（如果页面被销毁）
    ↓
Component.onDestruction
```

---

## 4. 导航操作 API

### 4.1 pushPage（进入子页面）

```qml
// 从主页进入设置页
Button {
    text: "设置"
    onClicked: {
        pageRegistry.navigateTo("settings")
    }
}

// 带参数导航
Button {
    text: "查看文件"
    onClicked: {
        pageRegistry.navigateTo("files", {
            "initialPath": "/gcodes",
            "filterPattern": "*.gcode"
        })
    }
}
```

### 4.2 popPage（返回上一级）

```qml
// Return 按钮
NavigationButton {
    enabled: stackView.depth > 1
    onClicked: {
        stackView.pop()
        navigationManager.popPage()  // 同步 Python 端
    }
}

// 页面内返回按钮（如果需要）
Button {
    text: "返回"
    visible: stackView.depth > 1
    onClicked: stackView.pop()
}
```

### 4.3 popToRoot（返回主页）

```qml
// HOME 按钮
NavigationButton {
    onClicked: {
        stackView.pop(null)  // null = 弹出到根页面
        navigationManager.popToRoot()
    }
}
```

### 4.4 replacePage（替换当前页面）

```qml
// 登录成功后替换登录页为主页
Button {
    text: "登录"
    onClicked: {
        if (performLogin()) {
            stackView.replace(homePageComponent)
            navigationManager.popToRoot()
        }
    }
}
```

---

## 5. 深度管理

### 深度限制

```qml
StackView {
    id: stackView

    // 监听深度变化
    onDepthChanged: {
        console.log("当前深度:", depth)

        // 警告：深度过深
        if (depth > 10) {
            console.warn("导航深度超过 10 层，可能存在循环导航")
        }
    }

    // 辅助函数：当前深度
    function getCurrentDepth() {
        return depth
    }

    // 辅助函数：获取指定深度的页面
    function getPageAtDepth(depthIndex) {
        if (depthIndex >= 0 && depthIndex < depth) {
            return get(depthIndex)
        }
        return null
    }
}
```

### 深度查询

```qml
// 判断是否在根页面
readonly property bool isAtRoot: stackView.depth === 1

// 判断是否可以返回
readonly property bool canGoBack: stackView.depth > 1

// 获取当前页面
readonly property Item currentPage: stackView.currentItem
```

---

## 6. 转场动画规范

### Metro 风格转场

| 转场类型 | 动画效果 | 时长 | 缓动曲线 |
|---------|---------|------|---------|
| `pushEnter` | 淡入 + 右滑入 | 250ms | OutCubic |
| `pushExit` | 淡出 | 150ms | Linear |
| `popEnter` | 淡入 | 250ms | OutCubic |
| `popExit` | 淡出 + 右滑出 | 150ms | InCubic |

### 自定义转场

```qml
StackView {
    // 快速淡入淡出（适用于快速切换）
    property Transition fastFade: Transition {
        PropertyAnimation {
            property: "opacity"
            duration: Style.durationFast  // 150ms
            easing.type: Easing.Linear
        }
    }

    // 滑动转场（适用于层级导航）
    property Transition slideTransition: Transition {
        PropertyAnimation {
            properties: "x,opacity"
            duration: Style.durationNormal  // 250ms
            easing.type: Easing.OutCubic
        }
    }

    // 根据页面类型选择转场
    function pushPageWithTransition(component, useSlide) {
        if (useSlide) {
            pushEnter = slideTransition
        } else {
            pushEnter = fastFade
        }
        push(component)
    }
}
```

---

## 7. 错误处理

### 页面加载失败

```qml
QtObject {
    id: pageRegistry

    function navigateTo(pageId, properties) {
        try {
            var component = pages[pageId]
            if (!component) {
                throw new Error("未注册的页面: " + pageId)
            }

            // 检查组件状态
            if (component.status === Component.Error) {
                throw new Error("页面加载失败: " + component.errorString())
            }

            stackView.push(component, properties || {})
            navigationManager.pushPage(pageId)
            return true

        } catch (error) {
            console.error("导航失败:", error.message)
            showErrorToast("无法打开页面: " + pageId)
            return false
        }
    }
}
```

### 导航栈损坏恢复

```qml
// 定期检查导航栈健康状态
Timer {
    interval: 5000  // 5秒
    running: true
    repeat: true

    onTriggered: {
        // 检查深度异常
        if (stackView.depth < 1) {
            console.error("导航栈损坏，重置到主页")
            stackView.clear()
            stackView.push(homePageComponent)
            navigationManager.popToRoot()
        }
    }
}
```

---

## 8. 性能优化

### 页面预加载

```qml
// 预加载常用页面（可选）
Component.onCompleted: {
    // 预创建组件实例（不push到栈）
    var preloadPages = ["control", "files"]
    for (var i = 0; i < preloadPages.length; i++) {
        var pageId = preloadPages[i]
        var comp = pageRegistry.pages[pageId]
        if (comp) {
            comp.incubateObject(stackView, {})
        }
    }
}
```

### 延迟初始化

```qml
Page {
    id: heavyPage

    // 延迟加载重量级内容
    property bool contentLoaded: false

    StackView.onActivated: {
        if (!contentLoaded) {
            loadHeavyContent()
            contentLoaded = true
        }
    }

    function loadHeavyContent() {
        // 延迟 100ms 后加载，让动画先完成
        Qt.callLater(() => {
            // 加载图表、列表等
        })
    }
}
```

### 内存管理

```qml
StackView {
    // 当栈深度 > 5 时，销毁底部页面
    onDepthChanged: {
        if (depth > 5) {
            // 保留前 3 个页面，销毁更早的
            var toRemove = depth - 5
            for (var i = 0; i < toRemove; i++) {
                var oldPage = get(i)
                if (oldPage && oldPage.pageId !== "home") {
                    // 销毁页面
                    oldPage.destroy()
                }
            }
        }
    }
}
```

---

## 9. 测试契约

### 导航测试用例

```qml
// tests/tst_navigation.qml

import QtTest 1.0
import QtQuick 2.0

TestCase {
    name: "NavigationTests"

    StackView {
        id: testStack
        initialItem: Page { objectName: "home" }
    }

    function test_push_page() {
        compare(testStack.depth, 1)

        testStack.push(Page { objectName: "settings" })
        compare(testStack.depth, 2)
        compare(testStack.currentItem.objectName, "settings")
    }

    function test_pop_page() {
        testStack.push(Page { objectName: "page1" })
        testStack.push(Page { objectName: "page2" })

        testStack.pop()
        compare(testStack.depth, 2)
        compare(testStack.currentItem.objectName, "page1")
    }

    function test_pop_to_root() {
        testStack.push(Page { objectName: "page1" })
        testStack.push(Page { objectName: "page2" })
        testStack.push(Page { objectName: "page3" })

        testStack.pop(null)
        compare(testStack.depth, 1)
        compare(testStack.currentItem.objectName, "home")
    }

    function test_lifecycle_signals() {
        var activatedCalled = false
        var deactivatedCalled = false

        var testPage = Page {
            StackView.onActivated: { activatedCalled = true }
            StackView.onDeactivated: { deactivatedCalled = true }
        }

        testStack.push(testPage)
        wait(300)  // 等待动画完成
        verify(activatedCalled)

        testStack.pop()
        wait(300)
        verify(deactivatedCalled)
    }
}
```

---

## 总结

本契约定义了：
- ✅ StackView 基础配置和转场动画
- ✅ 页面注册表和动态加载机制
- ✅ 完整的页面生命周期 API
- ✅ 导航操作方法（push/pop/replace）
- ✅ 深度管理和查询
- ✅ 错误处理和恢复策略
- ✅ 性能优化（预加载、延迟初始化、内存管理）
- ✅ 测试用例示例

**下一步**: 生成 `widget-api.md` 契约文档，定义 Widget 交互规范。
