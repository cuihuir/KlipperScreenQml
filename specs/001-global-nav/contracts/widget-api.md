# Widget 交互 API 契约

**功能分支**: `001-global-nav`
**创建日期**: 2025-11-27
**版本**: 1.0.0

## 概述

本文档定义主页 Widget 的交互规范，包括数据绑定、状态管理、用户交互和视觉反馈。

---

## 1. Widget 基类规范

### HomeWidget 基础组件

```qml
// qml/components/HomeWidget.qml

import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    // ===== 公共属性 =====
    property string widgetId: ""      // Widget 唯一标识
    property string title: ""         // Widget 标题
    property string widgetState: "idle"  // idle | active | updating | error
    property bool isInteractive: true // 是否可交互
    property real lastUpdateTime: 0.0 // 最后更新时间

    // ===== 视觉属性 =====
    width: 300
    height: 150
    radius: Style.radiusSmall
    color: Style.bgSecondary
    border.width: widgetState === "active" ? 2 : 0
    border.color: Style.accent

    // ===== 状态定义 =====
    states: [
        State {
            name: "idle"
            when: widgetState === "idle"
            PropertyChanges {
                target: root
                opacity: 1.0
            }
        },
        State {
            name: "active"
            when: widgetState === "active"
            PropertyChanges {
                target: root
                opacity: 1.0
                border.width: 2
            }
        },
        State {
            name: "updating"
            when: widgetState === "updating"
            PropertyChanges {
                target: loadingIndicator
                visible: true
                running: true
            }
        },
        State {
            name: "error"
            when: widgetState === "error"
            PropertyChanges {
                target: root
                border.width: 2
                border.color: Style.error
            }
        }
    ]

    // ===== 状态转场动画 =====
    transitions: [
        Transition {
            from: "*"
            to: "*"
            PropertyAnimation {
                properties: "opacity,border.width"
                duration: Style.durationFast
                easing.type: Easing.InOutQuad
            }
            ColorAnimation {
                property: "border.color"
                duration: Style.durationFast
            }
        }
    ]

    // ===== 加载指示器 =====
    Row {
        id: loadingIndicator
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Style.spacingSmall
        spacing: 8
        visible: false

        Repeater {
            model: 3
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: Style.accent

                SequentialAnimation on opacity {
                    running: loadingIndicator.visible
                    loops: Animation.Infinite
                    PropertyAnimation { to: 0.3; duration: 400 }
                    PropertyAnimation { to: 1.0; duration: 400 }
                    PauseAnimation { duration: index * 200 }
                }
            }
        }
    }

    // ===== 错误指示器 =====
    Label {
        id: errorLabel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: Style.spacingSmall
        text: "⚠ 错误"
        color: Style.error
        visible: widgetState === "error"
    }
}
```

---

## 2. TempWidget 实现

### 2.1 组件定义

```qml
// qml/components/TempWidget.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

HomeWidget {
    id: tempWidget

    // ===== 扩展属性 =====
    property string heaterName: "extruder"  // extruder | bed
    property real currentTemp: 0.0
    property real targetTemp: 0.0
    property int maxTemp: 300
    property bool isHeating: currentTemp < targetTemp - 5
    property bool keypadVisible: false

    widgetId: "temp_" + heaterName
    title: heaterName === "extruder" ? "喷头温度" : "热床温度"

    // ===== 数据绑定（从 MoonrakerClient） =====
    Connections {
        target: printer
        function onTemperatureUpdated(data) {
            if (data.hasOwnProperty(heaterName)) {
                currentTemp = data[heaterName].current
                targetTemp = data[heaterName].target
                lastUpdateTime = Date.now()
            }
        }
    }

    // ===== 布局 =====
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingNormal
        spacing: Style.spacingSmall

        // 标题
        Label {
            text: tempWidget.title
            font.pixelSize: Style.fontSizeSmall
            color: Style.textSecondary
        }

        // 当前温度（大号显示）
        Label {
            id: currentTempLabel
            text: currentTemp.toFixed(1) + "°C"
            font.pixelSize: Style.fontSizeXLarge
            font.family: Style.fontMonospace
            color: getTempColor()

            // 平滑数字动画
            property real displayTemp: 0

            Behavior on displayTemp {
                SmoothedAnimation {
                    velocity: 50  // 50°/秒
                    duration: 1000
                }
            }

            onCurrentTempChanged: {
                displayTemp = currentTemp
            }

            Component.onCompleted: {
                displayTemp = currentTemp
            }

            function getTempColor() {
                if (heaterName === "extruder") {
                    return currentTemp > 200 ? Style.error : Style.info
                } else {
                    return currentTemp > 80 ? Style.warning : Style.info
                }
            }
        }

        // 目标温度
        Label {
            text: "目标: " + targetTemp.toFixed(0) + "°C"
            font.pixelSize: Style.fontSizeSmall
            color: Style.textSecondary
            visible: targetTemp > 0
        }

        // 加热指示器
        Row {
            spacing: Style.spacingSmall
            visible: isHeating

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: Style.warning

                SequentialAnimation on opacity {
                    running: isHeating
                    loops: Animation.Infinite
                    PropertyAnimation { to: 0.3; duration: 800 }
                    PropertyAnimation { to: 1.0; duration: 800 }
                }
            }

            Label {
                text: "加热中"
                font.pixelSize: Style.fontSizeSmall
                color: Style.warning
            }
        }

        Item { Layout.fillHeight: true }  // 弹簧
    }

    // ===== 点击打开键盘 =====
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (isInteractive) {
                showKeypad()
            }
        }

        // 悬停反馈
        hoverEnabled: true
        Rectangle {
            anchors.fill: parent
            color: Style.textPrimary
            opacity: parent.containsMouse ? 0.1 : 0
            radius: tempWidget.radius

            Behavior on opacity {
                NumberAnimation { duration: Style.durationFast }
            }
        }
    }

    // ===== 数字键盘弹出层 =====
    Popup {
        id: tempKeypad
        anchors.centerIn: parent
        width: 400
        height: 500
        modal: false
        dim: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        z: 100

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: 200; easing.type: Easing.OutBack }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
        }

        NumericKeypad {
            anchors.fill: parent
            title: "设置 " + tempWidget.title
            maxLength: 3
            placeholder: targetTemp > 0 ? targetTemp.toFixed(0) : "000"

            onConfirmed: function(value) {
                var temp = parseInt(value)
                if (temp >= 0 && temp <= tempWidget.maxTemp) {
                    printer.setExtruderTemp(tempWidget.heaterName, temp)
                    tempKeypad.close()
                } else {
                    showErrorToast("温度超出范围：0-" + tempWidget.maxTemp)
                }
            }

            onCancelled: {
                tempKeypad.close()
            }
        }
    }

    // ===== 辅助方法 =====
    function showKeypad() {
        keypadVisible = true
        tempKeypad.open()
    }

    function hideKeypad() {
        keypadVisible = false
        tempKeypad.close()
    }
}
```

---

## 3. PrintControlWidget 实现

### 3.1 状态切换逻辑

```qml
// qml/components/PrintControlWidget.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

HomeWidget {
    id: printWidget

    // ===== 扩展属性 =====
    property string printState: "idle"  // idle | printing | paused | complete | error
    property real progress: 0.0         // 0.0 - 100.0
    property int currentLayer: 0
    property int totalLayers: 0
    property string fileName: ""
    property int estimatedTimeRemaining: 0  // 秒
    property string thumbnailPath: ""

    widgetId: "print_control"
    title: "打印控制"
    width: 620
    height: 312

    // ===== 数据绑定 =====
    Connections {
        target: printer
        function onPrintStateChanged(state) {
            printState = state
        }
        function onPrintProgressChanged(data) {
            progress = data.progress
            currentLayer = data.current_layer
            totalLayers = data.total_layers
            fileName = data.filename
            estimatedTimeRemaining = data.estimated_time
        }
    }

    // ===== 状态驱动的 UI =====
    Loader {
        anchors.fill: parent
        sourceComponent: {
            switch (printState) {
                case "idle":
                    return idleComponent
                case "printing":
                case "paused":
                    return printingComponent
                case "complete":
                    return completeComponent
                case "error":
                    return errorComponent
                default:
                    return idleComponent
            }
        }
    }

    // ===== 空闲状态：超大开始按钮 =====
    Component {
        id: idleComponent

        Rectangle {
            color: Style.bgSecondary
            radius: Style.radiusSmall

            MetroButton {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: 100
                text: "开始打印"
                fontSize: Style.fontSizeLarge
                backgroundColor: Style.success

                onClicked: {
                    // 导航到文件选择页
                    pageRegistry.navigateTo("files", {
                        "mode": "select"
                    })
                }
            }
        }
    }

    // ===== 打印中状态：进度卡片 =====
    Component {
        id: printingComponent

        Rectangle {
            color: Style.bgSecondary
            radius: Style.radiusSmall

            // ===== 背景区域（点击进入详情） =====
            MouseArea {
                id: cardArea
                anchors.fill: parent
                z: 0

                onClicked: {
                    // 导航到打印详情页
                    pageRegistry.navigateTo("printing")
                }

                // 悬停反馈
                Rectangle {
                    anchors.fill: parent
                    color: Style.textPrimary
                    opacity: parent.containsMouse ? 0.05 : 0
                    radius: parent.radius
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingNormal
                spacing: Style.spacingNormal

                // 文件名
                Label {
                    text: fileName
                    font.pixelSize: Style.fontSizeNormal
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // 进度条
                ProgressBar {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: progress

                    background: Rectangle {
                        color: Style.bgPrimary
                        radius: 2
                    }

                    contentItem: Rectangle {
                        width: parent.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: Style.accent

                        Behavior on width {
                            NumberAnimation { duration: 500 }
                        }
                    }
                }

                // 进度百分比
                Label {
                    text: progress.toFixed(1) + "%"
                    font.pixelSize: Style.fontSizeXLarge
                    font.family: Style.fontMonospace
                    color: Style.accent
                }

                // 图层信息
                Label {
                    text: "图层: " + currentLayer + " / " + totalLayers
                    font.pixelSize: Style.fontSizeSmall
                    color: Style.textSecondary
                }

                // 剩余时间
                Label {
                    text: "剩余: " + formatTime(estimatedTimeRemaining)
                    font.pixelSize: Style.fontSizeSmall
                    color: Style.textSecondary
                }

                Item { Layout.fillHeight: true }

                // ===== 快捷按钮（高 z-order） =====
                Row {
                    spacing: Style.spacingNormal
                    z: 10  // 高优先级

                    MetroButton {
                        text: printState === "printing" ? "暂停" : "继续"
                        width: 100
                        height: 40
                        backgroundColor: Style.warning

                        onClicked: {
                            if (printState === "printing") {
                                printer.pausePrint()
                            } else {
                                printer.resumePrint()
                            }
                            mouse.accepted = true  // 阻止事件传播
                        }
                    }

                    MetroButton {
                        text: "取消"
                        width: 100
                        height: 40
                        backgroundColor: Style.error

                        onClicked: {
                            confirmDialog.open()
                            mouse.accepted = true
                        }
                    }
                }
            }
        }
    }

    // ===== 完成状态 =====
    Component {
        id: completeComponent

        Rectangle {
            color: Style.bgSecondary
            radius: Style.radiusSmall

            Column {
                anchors.centerIn: parent
                spacing: Style.spacingLarge

                Label {
                    text: "✓ 打印完成"
                    font.pixelSize: Style.fontSizeLarge
                    color: Style.success
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    text: fileName
                    font.pixelSize: Style.fontSizeNormal
                    color: Style.textPrimary
                }
            }

            // 3秒后自动回到空闲状态
            Timer {
                interval: 3000
                running: true
                onTriggered: {
                    printState = "idle"
                }
            }
        }
    }

    // ===== 错误状态 =====
    Component {
        id: errorComponent

        Rectangle {
            color: Style.bgSecondary
            radius: Style.radiusSmall

            Column {
                anchors.centerIn: parent
                spacing: Style.spacingLarge

                Label {
                    text: "⚠ 打印错误"
                    font.pixelSize: Style.fontSizeLarge
                    color: Style.error
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MetroButton {
                    text: "重试"
                    onClicked: {
                        printer.startPrint(fileName)
                    }
                }

                MetroButton {
                    text: "取消"
                    onClicked: {
                        printState = "idle"
                    }
                }
            }
        }
    }

    // ===== 取消确认对话框 =====
    ConfirmDialog {
        id: confirmDialog
        title: "取消打印"
        message: "确定要取消当前打印吗？"

        onAccepted: {
            printer.cancelPrint()
        }
    }

    // ===== 辅助方法 =====
    function formatTime(seconds) {
        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        return hours + "h " + minutes + "m"
    }
}
```

---

## 4. FanWidget / LedWidget 实现

### 4.1 滑块控制组件

```qml
// qml/components/FanWidget.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

HomeWidget {
    id: fanWidget

    property string fanName: "fan"
    property bool isOn: false
    property real speed: 0.0  // 0.0 - 1.0

    widgetId: "fan_" + fanName
    title: "风扇"

    // 数据绑定
    Connections {
        target: printer
        function onFanStateChanged(name, on, spd) {
            if (name === fanWidget.fanName) {
                isOn = on
                speed = spd
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingNormal
        spacing: Style.spacingNormal

        Label {
            text: title
            font.pixelSize: Style.fontSizeSmall
            color: Style.textSecondary
        }

        Label {
            text: isOn ? "开启" : "关闭"
            font.pixelSize: Style.fontSizeLarge
            color: isOn ? Style.success : Style.textDisabled
        }

        Label {
            text: Math.round(speed * 100) + "%"
            font.pixelSize: Style.fontSizeXLarge
            font.family: Style.fontMonospace
            color: Style.accent
        }

        Slider {
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            value: speed
            stepSize: 0.05

            onPressedChanged: {
                if (!pressed) {
                    // 释放时发送命令
                    printer.setFanSpeed(fanWidget.fanName, value)
                }
            }

            background: Rectangle {
                width: parent.width
                height: 8
                radius: 4
                color: Style.bgPrimary

                Rectangle {
                    width: parent.parent.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Style.accent
                }
            }

            handle: Rectangle {
                x: parent.visualPosition * (parent.width - width)
                y: (parent.height - height) / 2
                width: 20
                height: 20
                radius: 10
                color: Style.accent
                border.width: 2
                border.color: Style.bgPrimary
            }
        }

        MetroButton {
            text: isOn ? "关闭" : "开启"
            Layout.fillWidth: true
            backgroundColor: isOn ? Style.error : Style.success

            onClicked: {
                printer.setFanOnOff(fanWidget.fanName, !isOn)
            }
        }

        Item { Layout.fillHeight: true }
    }
}
```

---

## 5. Widget 工厂模式

### 动态创建 Widget

```qml
// qml/pages/HomePage.qml

QtObject {
    id: widgetFactory

    // Widget 配置
    property var widgetConfigs: [
        {
            "type": "temp",
            "heaterName": "extruder",
            "col": 0,
            "row": 0
        },
        {
            "type": "temp",
            "heaterName": "bed",
            "col": 1,
            "row": 0
        },
        {
            "type": "fan",
            "fanName": "fan",
            "col": 2,
            "row": 0
        },
        {
            "type": "led",
            "ledName": "led",
            "col": 0,
            "row": 1
        },
        {
            "type": "print",
            "col": 1,
            "row": 1,
            "colSpan": 2,
            "rowSpan": 2
        }
    ]

    // Widget 组件映射
    property var widgetComponents: ({
        "temp": tempWidgetComponent,
        "fan": fanWidgetComponent,
        "led": ledWidgetComponent,
        "print": printWidgetComponent
    })

    Component { id: tempWidgetComponent; TempWidget {} }
    Component { id: fanWidgetComponent; FanWidget {} }
    Component { id: ledWidgetComponent; LedWidget {} }
    Component { id: printWidgetComponent; PrintControlWidget {} }

    // 创建 Widget
    function createWidget(config, parent) {
        var component = widgetComponents[config.type]
        if (!component) {
            console.error("未知 Widget 类型:", config.type)
            return null
        }

        return component.createObject(parent, config)
    }
}
```

---

## 总结

本契约定义了：
- ✅ HomeWidget 基类（状态管理、视觉反馈）
- ✅ TempWidget 完整实现（数据绑定、键盘交互、平滑动画）
- ✅ PrintControlWidget 状态机（idle/printing/paused/complete/error）
- ✅ FanWidget/LedWidget 滑块控制
- ✅ Widget 工厂模式（动态创建）
- ✅ 点击区域处理（z-order 分层）
- ✅ 性能优化（SmoothedAnimation、Behavior）

**下一步**: 生成 `quickstart.md`，提供开发者快速入门指南。
