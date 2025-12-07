import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components"

Page {
    id: root

    property var printer: null
    property StackView stackView: StackView.view
    property real moveDistance: 10
    property real extrudeDistance: 10

    background: Rectangle {
        color: Style.bgPrimary
    }

    // 主布局 - 固定宽度避免布局问题
    Item {
        anchors.fill: parent
        anchors.leftMargin: Style.spacingLarge
        anchors.topMargin: Style.spacingLarge
        anchors.rightMargin: Style.spacingLarge
        anchors.bottomMargin: Style.spacingLarge

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 40

            // ===== 列1: XY移动 (450px) =====
            Rectangle {
                width: 450
                height: 360
                color: Style.bgSecondary
                radius: Style.radiusSmall

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // 标题
                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "XY"
                            font.pixelSize: 18
                            font.bold: true
                            color: Style.textPrimary
                        }

                        Rectangle {
                            width: parent.width - 30
                            height: 32
                            color: Style.bgCard
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: "X:" + (printer ? printer.positionX.toFixed(1) : "0") + " Y:" + (printer ? printer.positionY.toFixed(1) : "0")
                                font.pixelSize: 14
                                font.family: Style.fontFamilyMono
                                color: Style.accent
                            }
                        }
                    }

                    // XY控制
                    Grid {
                        width: parent.width
                        height: 220
                        columns: 3
                        rows: 3
                        spacing: 4

                        property bool xHomed: printer && printer.homedAxes.includes("x")
                        property bool yHomed: printer && printer.homedAxes.includes("y")

                        Item { width: 140; height: 70 }

                        Rectangle {
                            width: 140; height: 70
                            color: (parent.yHomed || false) ? Style.accent : Style.bgTertiary
                            radius: 4
                            Text { anchors.centerIn: parent; text: "↑"; font.pixelSize: 36; color: "white" }
                            MouseArea { anchors.fill: parent; enabled: parent.parent.yHomed || false; onClicked: moveAxis("Y", "+") }
                        }

                        Item { width: 140; height: 70 }

                        Rectangle {
                            width: 140; height: 70
                            color: (parent.xHomed || false) ? Style.accent : Style.bgTertiary
                            radius: 4
                            Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 36; color: "white" }
                            MouseArea { anchors.fill: parent; enabled: parent.parent.xHomed || false; onClicked: moveAxis("X", "-") }
                        }

                        Rectangle {
                            width: 140; height: 70
                            color: Style.info
                            radius: 4
                            Text { anchors.centerIn: parent; text: "HOME"; font.pixelSize: 14; font.bold: true; color: "white" }
                            MouseArea { anchors.fill: parent; onClicked: sendGcode("G28 X Y") }
                        }

                        Rectangle {
                            width: 140; height: 70
                            color: (parent.xHomed || false) ? Style.accent : Style.bgTertiary
                            radius: 4
                            Text { anchors.centerIn: parent; text: "→"; font.pixelSize: 36; color: "white" }
                            MouseArea { anchors.fill: parent; enabled: parent.parent.xHomed || false; onClicked: moveAxis("X", "+") }
                        }

                        Item { width: 140; height: 70 }

                        Rectangle {
                            width: 140; height: 70
                            color: (parent.yHomed || false) ? Style.accent : Style.bgTertiary
                            radius: 4
                            Text { anchors.centerIn: parent; text: "↓"; font.pixelSize: 36; color: "white" }
                            MouseArea { anchors.fill: parent; enabled: parent.parent.yHomed || false; onClicked: moveAxis("Y", "-") }
                        }

                        Item { width: 140; height: 70 }
                    }

                    // 步长
                    Grid {
                        width: parent.width
                        height: 40
                        columns: 7
                        spacing: 2

                        Repeater {
                            model: [0.1, 1, 5, 10, 25, 50, 100]
                            Rectangle {
                                width: 62; height: 40
                                color: root.moveDistance === modelData ? Style.accent : Style.bgCard
                                radius: 4
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData >= 1 ? modelData : modelData.toFixed(1)
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: root.moveDistance === modelData ? "white" : Style.textPrimary
                                }
                                MouseArea { anchors.fill: parent; onClicked: root.moveDistance = modelData }
                            }
                        }
                    }
                }
            }

            // ===== 列2: Z轴 (220px) =====
            Rectangle {
                width: 220
                height: 360
                color: Style.bgSecondary
                radius: Style.radiusSmall

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Row {
                        width: parent.width
                        spacing: 4

                        Text {
                            text: "Z"
                            font.pixelSize: 18
                            font.bold: true
                            color: Style.textPrimary
                        }

                        Rectangle {
                            width: parent.width - 20
                            height: 32
                            color: Style.bgCard
                            radius: 4
                            Text {
                                anchors.centerIn: parent
                                text: (printer ? printer.positionZ.toFixed(2) : "0.00") + " mm"
                                font.pixelSize: 14
                                font.family: Style.fontFamilyMono
                                color: Style.warning
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        height: 310
                        spacing: 4

                        property bool zHomed: printer && printer.homedAxes.includes("z")

                        Rectangle {
                            width: parent.width
                            height: 100
                            color: (parent.zHomed || false) ? Style.warning : Style.bgTertiary
                            radius: 4
                            Text { anchors.centerIn: parent; text: "↑"; font.pixelSize: 48; color: "white" }
                            MouseArea { anchors.fill: parent; enabled: parent.parent.zHomed || false; onClicked: moveAxis("Z", "+") }
                        }

                        Rectangle {
                            width: parent.width
                            height: 100
                            color: Style.info
                            radius: 4
                            Text { anchors.centerIn: parent; text: "Z\nHOME"; font.pixelSize: 14; font.bold: true; color: "white"; horizontalAlignment: Text.AlignHCenter }
                            MouseArea { anchors.fill: parent; onClicked: sendGcode("G28 Z") }
                        }

                        Rectangle {
                            width: parent.width
                            height: 100
                            color: (parent.zHomed || false) ? Style.warning : Style.bgTertiary
                            radius: 4
                            Text { anchors.centerIn: parent; text: "↓"; font.pixelSize: 48; color: "white" }
                            MouseArea { anchors.fill: parent; enabled: parent.parent.zHomed || false; onClicked: moveAxis("Z", "-") }
                        }
                    }
                }
            }

            // ===== 列3: 挤出 (420px) =====
            Rectangle {
                width: 420
                height: 360
                color: Style.bgSecondary
                radius: Style.radiusSmall

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // 左侧: Extrude/Retract 三角形控制
                    Column {
                        width: 160
                        height: parent.height
                        spacing: 8

                        Text {
                            text: "E"
                            font.pixelSize: 18
                            font.bold: true
                            color: Style.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            // Extrude (上三角)
                            Rectangle {
                                width: parent.width
                                height: 100
                                color: Style.success
                                radius: 4
                                Text {
                                    anchors.centerIn: parent
                                    text: "▲"
                                    font.pixelSize: 48
                                    color: "white"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: extrudeFilament(root.extrudeDistance)
                                }
                            }

                            // 距离显示
                            Rectangle {
                                width: parent.width
                                height: 50
                                color: Style.bgCard
                                radius: 4
                                Text {
                                    anchors.centerIn: parent
                                    text: root.extrudeDistance + " mm"
                                    font.pixelSize: 14
                                    font.family: Style.fontFamilyMono
                                    color: Style.accent
                                }
                            }

                            // Retract (下三角)
                            Rectangle {
                                width: parent.width
                                height: 100
                                color: Style.error
                                radius: 4
                                Text {
                                    anchors.centerIn: parent
                                    text: "▼"
                                    font.pixelSize: 48
                                    color: "white"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: extrudeFilament(-root.extrudeDistance)
                                }
                            }

                            // 距离选择器
                            Grid {
                                width: parent.width
                                columns: 3
                                spacing: 2

                                Repeater {
                                    model: [1, 5, 10, 25, 50, 100]
                                    Rectangle {
                                        width: 52; height: 32
                                        color: root.extrudeDistance === modelData ? Style.accent : Style.bgCard
                                        radius: 4
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.pixelSize: 11
                                            font.bold: true
                                            color: root.extrudeDistance === modelData ? "white" : Style.textPrimary
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: root.extrudeDistance = modelData }
                                    }
                                }
                            }
                        }
                    }

                    // 右侧: 进料/退料流程控制
                    Column {
                        width: 220
                        height: parent.height
                        spacing: 8

                        Text {
                            text: "装卸料"
                            font.pixelSize: 18
                            font.bold: true
                            color: Style.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Column {
                            width: parent.width
                            spacing: 12

                            Rectangle {
                                width: parent.width
                                height: 140
                                color: Style.success
                                radius: 4
                                border.width: 2
                                border.color: Qt.darker(Style.success, 1.2)

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: "进料"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "white"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "Load Filament"
                                        font.pixelSize: 12
                                        color: "white"
                                        opacity: 0.8
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        // 完整进料流程: 加热 -> 挤出50mm
                                        sendGcode("M104 S200\nG4 P5000\nM83\nG1 E50 F300\nM82")
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 140
                                color: Style.error
                                radius: 4
                                border.width: 2
                                border.color: Qt.darker(Style.error, 1.2)

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: "退料"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "white"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "Unload Filament"
                                        font.pixelSize: 12
                                        color: "white"
                                        opacity: 0.8
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        // 完整退料流程: 加热 -> 回退50mm
                                        sendGcode("M104 S200\nG4 P5000\nM83\nG1 E-50 F300\nM82")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ===== 列4: 其他 (350px) =====
            Column {
                width: 350
                height: 360
                spacing: 12

                Rectangle {
                    width: parent.width
                    height: 174
                    color: Style.bgSecondary
                    radius: Style.radiusSmall

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        width: parent.width - 24

                        Text {
                            text: "温度"
                            font.pixelSize: 16
                            font.bold: true
                            color: Style.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "热端:"
                                font.pixelSize: 14
                                color: Style.textSecondary
                                width: 50
                            }
                            Text {
                                text: (printer ? printer.hotendTemp.toFixed(0) : "0") + "°C / " + (printer ? printer.hotendTarget.toFixed(0) : "0") + "°C"
                                font.pixelSize: 14
                                font.family: Style.fontFamilyMono
                                color: Style.accent
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "热床:"
                                font.pixelSize: 14
                                color: Style.textSecondary
                                width: 50
                            }
                            Text {
                                text: (printer ? printer.bedTemp.toFixed(0) : "0") + "°C / " + (printer ? printer.bedTarget.toFixed(0) : "0") + "°C"
                                font.pixelSize: 14
                                font.family: Style.fontFamilyMono
                                color: Style.accent
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.stackView) {
                                root.stackView.push(Qt.resolvedUrl("TemperatureControlPage.qml"), {"printer": root.printer})
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 174
                    color: Style.bgCard
                    radius: Style.radiusSmall

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: "⋯"
                            font.pixelSize: 48
                            color: Style.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "更多控制"
                            font.pixelSize: 16
                            font.bold: true
                            color: Style.textPrimary
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.stackView) {
                                root.stackView.push(Qt.resolvedUrl("ControlLevel2.qml"))
                            }
                        }
                    }
                }
            }
        }
    }

    function moveAxis(axis, direction) {
        var gcode = "G91\nG1 " + axis + (direction === "+" ? "" : "-") + moveDistance + " F3000\nG90"
        sendGcode(gcode)
    }

    function extrudeFilament(distance) {
        var gcode = "M83\nG1 E" + distance + " F300\nM82"
        sendGcode(gcode)
    }

    function sendGcode(gcode) {
        if (!printer) return
        printer.sendGcode(gcode)
    }
}
