import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// Metro风格打印微调页
Page {
    id: root
    property var printer: null
    property var app: null

    signal showError(string message)

    background: Rectangle {
        color: Style.bgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // 顶部标题
        Label {
            text: "打印微调"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 3
            color: Style.textPrimary
            Layout.fillWidth: true
        }

        // 主内容区域 - 2x2 网格
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rows: 2
            rowSpacing: Style.spacingLarge
            columnSpacing: Style.spacingLarge

            // 1. 速度倍率
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingMedium

                    // 标题
                    Label {
                        text: "速度倍率"
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.textPrimary
                    }

                    // 当前值显示
                    Label {
                        text: (printer ? Math.round(printer.speedFactor * 100) : 100) + "%"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.accent
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // 滑块
                    Slider {
                        id: speedSlider
                        Layout.fillWidth: true
                        from: 10
                        to: 200
                        value: printer ? printer.speedFactor * 100 : 100
                        stepSize: 5

                        onPressedChanged: {
                            if (!pressed && printer) {
                                // 释放时发送 G-code
                                var gcode = "M220 S" + Math.round(value)
                                printer.sendGcode(gcode)
                                console.log("Speed factor set to:", value + "%")
                            }
                        }

                        background: Rectangle {
                            x: speedSlider.leftPadding
                            y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                            width: speedSlider.availableWidth
                            height: Style.baseUnit
                            color: Style.bgSecondary
                            radius: height / 2

                            Rectangle {
                                width: speedSlider.visualPosition * parent.width
                                height: parent.height
                                color: Style.accent
                                radius: height / 2
                            }
                        }

                        handle: Rectangle {
                            x: speedSlider.leftPadding + speedSlider.visualPosition * (speedSlider.availableWidth - width)
                            y: speedSlider.topPadding + speedSlider.availableHeight / 2 - height / 2
                            width: Style.baseUnit * 3
                            height: Style.baseUnit * 3
                            radius: width / 2
                            color: speedSlider.pressed ? Style.accentHover : Style.accent
                            border.width: Style.borderMedium
                            border.color: Style.bgPrimary
                        }
                    }

                    // 范围标签
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "10%"
                            font.pixelSize: Style.fontSmall
                            color: Style.textSecondary
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "200%"
                            font.pixelSize: Style.fontSmall
                            color: Style.textSecondary
                        }
                    }

                    // 快捷按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacingSmall

                        Repeater {
                            model: [50, 75, 100, 125, 150]
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.baseUnit * 4
                                color: speedSlider.value === modelData ? Style.accent : Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData + "%"
                                    font.pixelSize: Style.fontMedium
                                    font.bold: true
                                    color: speedSlider.value === modelData ? Style.bgPrimary : Style.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        speedSlider.value = modelData
                                        if (printer) {
                                            printer.sendGcode("M220 S" + modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 2. 挤出倍率
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingMedium

                    Label {
                        text: "挤出倍率"
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.textPrimary
                    }

                    Label {
                        text: (printer ? Math.round(printer.extrudeFactor * 100) : 100) + "%"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.success
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Slider {
                        id: extrudeSlider
                        Layout.fillWidth: true
                        from: 75
                        to: 125
                        value: printer ? printer.extrudeFactor * 100 : 100
                        stepSize: 1

                        onPressedChanged: {
                            if (!pressed && printer) {
                                var gcode = "M221 S" + Math.round(value)
                                printer.sendGcode(gcode)
                                console.log("Extrude factor set to:", value + "%")
                            }
                        }

                        background: Rectangle {
                            x: extrudeSlider.leftPadding
                            y: extrudeSlider.topPadding + extrudeSlider.availableHeight / 2 - height / 2
                            width: extrudeSlider.availableWidth
                            height: Style.baseUnit
                            color: Style.bgSecondary
                            radius: height / 2

                            Rectangle {
                                width: extrudeSlider.visualPosition * parent.width
                                height: parent.height
                                color: Style.success
                                radius: height / 2
                            }
                        }

                        handle: Rectangle {
                            x: extrudeSlider.leftPadding + extrudeSlider.visualPosition * (extrudeSlider.availableWidth - width)
                            y: extrudeSlider.topPadding + extrudeSlider.availableHeight / 2 - height / 2
                            width: Style.baseUnit * 3
                            height: Style.baseUnit * 3
                            radius: width / 2
                            color: extrudeSlider.pressed ? Qt.darker(Style.success, 1.1) : Style.success
                            border.width: Style.borderMedium
                            border.color: Style.bgPrimary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "75%"
                            font.pixelSize: Style.fontSmall
                            color: Style.textSecondary
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "125%"
                            font.pixelSize: Style.fontSmall
                            color: Style.textSecondary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacingSmall

                        Repeater {
                            model: [90, 95, 100, 105, 110]
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.baseUnit * 4
                                color: extrudeSlider.value === modelData ? Style.success : Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData + "%"
                                    font.pixelSize: Style.fontMedium
                                    font.bold: true
                                    color: extrudeSlider.value === modelData ? Style.bgPrimary : Style.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        extrudeSlider.value = modelData
                                        if (printer) {
                                            printer.sendGcode("M221 S" + modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 3. 风扇速度
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingMedium

                    Label {
                        text: "风扇速度"
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.textPrimary
                    }

                    Label {
                        id: fanSpeedLabel
                        text: "0%"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.info
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Slider {
                        id: fanSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: 0
                        stepSize: 5

                        onPressedChanged: {
                            if (!pressed && printer) {
                                var speed = Math.round(value * 255 / 100)
                                var gcode = "M106 S" + speed
                                printer.sendGcode(gcode)
                                console.log("Fan speed set to:", value + "%")
                            }
                        }

                        onValueChanged: {
                            fanSpeedLabel.text = Math.round(value) + "%"
                        }

                        background: Rectangle {
                            x: fanSlider.leftPadding
                            y: fanSlider.topPadding + fanSlider.availableHeight / 2 - height / 2
                            width: fanSlider.availableWidth
                            height: Style.baseUnit
                            color: Style.bgSecondary
                            radius: height / 2

                            Rectangle {
                                width: fanSlider.visualPosition * parent.width
                                height: parent.height
                                color: Style.info
                                radius: height / 2
                            }
                        }

                        handle: Rectangle {
                            x: fanSlider.leftPadding + fanSlider.visualPosition * (fanSlider.availableWidth - width)
                            y: fanSlider.topPadding + fanSlider.availableHeight / 2 - height / 2
                            width: Style.baseUnit * 3
                            height: Style.baseUnit * 3
                            radius: width / 2
                            color: fanSlider.pressed ? Qt.darker(Style.info, 1.1) : Style.info
                            border.width: Style.borderMedium
                            border.color: Style.bgPrimary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "关闭"
                            font.pixelSize: Style.fontSmall
                            color: Style.textSecondary
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "最大"
                            font.pixelSize: Style.fontSmall
                            color: Style.textSecondary
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacingSmall

                        Repeater {
                            model: [0, 25, 50, 75, 100]
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.baseUnit * 4
                                color: fanSlider.value === modelData ? Style.info : Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData + "%"
                                    font.pixelSize: Style.fontMedium
                                    font.bold: true
                                    color: fanSlider.value === modelData ? Style.bgPrimary : Style.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        fanSlider.value = modelData
                                        if (printer) {
                                            var speed = Math.round(modelData * 255 / 100)
                                            printer.sendGcode("M106 S" + speed)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 4. Z 轴偏移
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingMedium

                    Label {
                        text: "Z 轴偏移"
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.textPrimary
                    }

                    Label {
                        id: zOffsetLabel
                        text: (printer ? printer.zOffset.toFixed(3) : "0.000") + " mm"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.warning
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // 调整按钮 +/-
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: Style.spacingSmall
                        columnSpacing: Style.spacingSmall

                        // +0.1
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 6
                            color: Style.warning
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "+0.1"
                                font.pixelSize: Style.fontLarge
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: adjustZOffset(0.1)
                            }
                        }

                        // +0.05
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 6
                            color: Style.warning
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "+0.05"
                                font.pixelSize: Style.fontLarge
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: adjustZOffset(0.05)
                            }
                        }

                        // +0.01
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 6
                            color: Style.warning
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "+0.01"
                                font.pixelSize: Style.fontLarge
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: adjustZOffset(0.01)
                            }
                        }

                        // -0.1
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 6
                            color: Style.error
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "-0.1"
                                font.pixelSize: Style.fontLarge
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: adjustZOffset(-0.1)
                            }
                        }

                        // -0.05
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 6
                            color: Style.error
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "-0.05"
                                font.pixelSize: Style.fontLarge
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: adjustZOffset(-0.05)
                            }
                        }

                        // -0.01
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 6
                            color: Style.error
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "-0.01"
                                font.pixelSize: Style.fontLarge
                                font.bold: true
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: adjustZOffset(-0.01)
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    // 监听数据更新
    Connections {
        target: printer
        enabled: printer !== null

        function onFanStateChanged(fan, speed) {
            if (fan === "fan") {
                fanSlider.value = Math.round(speed * 100)
            }
        }
    }

    // 辅助函数
    function adjustZOffset(delta) {
        if (!printer) return

        // 发送 SET_GCODE_OFFSET Z_ADJUST
        var gcode = "SET_GCODE_OFFSET Z_ADJUST=" + delta.toFixed(3)
        printer.sendGcode(gcode)
        console.log("Z offset adjusted by:", delta)
    }

    Component.onCompleted: {
        console.log("FineTunePage created")
    }
}
