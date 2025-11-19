import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

import "../components" as Components

// Metro风格移动控制页
Page {
    id: root
    property var printer: null
    property var app: null
    property real currentDistance: 10

    signal showError(string message)

    // 判断各轴是否已归零
    readonly property bool xHomed: printer && printer.homedAxes.includes("x")
    readonly property bool yHomed: printer && printer.homedAxes.includes("y")
    readonly property bool zHomed: printer && printer.homedAxes.includes("z")
    readonly property bool xyHomed: xHomed && yHomed

    background: Rectangle {
        color: Style.bgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // 顶部 - Position信息横向显示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 4
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.spacingMedium
                anchors.rightMargin: Style.spacingMedium
                spacing: Style.spacingLarge

                // X Position
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingSmall

                    Label {
                        text: "X"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 2
                        color: Style.textSecondary
                        Layout.preferredWidth: Style.baseUnit * 2
                    }

                    Label {
                        text: printer ? printer.positionX.toFixed(2) : "0.00"
                        font.pixelSize: Style.fontXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.accent
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "mm"
                        font.pixelSize: Style.fontSmall
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                }

                Rectangle {
                    width: Style.borderMedium
                    Layout.fillHeight: true
                    Layout.topMargin: Style.spacingSmall
                    Layout.bottomMargin: Style.spacingSmall
                    color: Style.divider
                }

                // Y Position
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingSmall

                    Label {
                        text: "Y"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 2
                        color: Style.textSecondary
                        Layout.preferredWidth: Style.baseUnit * 2
                    }

                    Label {
                        text: printer ? printer.positionY.toFixed(2) : "0.00"
                        font.pixelSize: Style.fontXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.accent
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "mm"
                        font.pixelSize: Style.fontSmall
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                }

                Rectangle {
                    width: Style.borderMedium
                    Layout.fillHeight: true
                    Layout.topMargin: Style.spacingSmall
                    Layout.bottomMargin: Style.spacingSmall
                    color: Style.divider
                }

                // Z Position
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingSmall

                    Label {
                        text: "Z"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 2
                        color: Style.textSecondary
                        Layout.preferredWidth: Style.baseUnit * 2
                    }

                    Label {
                        text: printer ? printer.positionZ.toFixed(2) : "0.00"
                        font.pixelSize: Style.fontXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.accent
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "mm"
                        font.pixelSize: Style.fontSmall
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                }
            }
        }

        // 中间 - 控制区域 (使用GridLayout统一控制宽度)
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rows: 3
            rowSpacing: Style.spacingSmall
            columnSpacing: Style.spacingSmall

            // Row 0: Empty, Y+, Empty, Z+, Empty, Empty, Empty
            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: yHomed ? Style.accent : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                opacity: yHomed ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "↑"
                    font.pixelSize: Style.fontXXLarge
                    font.bold: true
                    color: yHomed ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: yHomed
                    cursorShape: yHomed ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: moveAxis("Y", "+")
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: zHomed ? Style.warning : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                opacity: zHomed ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "Z ↑"
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: zHomed ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: zHomed
                    cursorShape: zHomed ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: moveAxis("Z", "+")
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.success
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "EXTRUDE"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: extrudeFilament(currentDistance)
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            // Row 1: X-, HOME, X+, Z HOME, Empty, Empty, Empty
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: xHomed ? Style.accent : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                opacity: xHomed ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: Style.fontXXLarge
                    font.bold: true
                    color: xHomed ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: xHomed
                    cursorShape: xHomed ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: moveAxis("X", "-")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.info
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "HOME"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sendGcode("G28")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: xHomed ? Style.accent : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                opacity: xHomed ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "→"
                    font.pixelSize: Style.fontXXLarge
                    font.bold: true
                    color: xHomed ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: xHomed
                    cursorShape: xHomed ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: moveAxis("X", "+")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.info
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "Z\nHOME"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.bgPrimary
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sendGcode("G28 Z")
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            // Row 2: Empty, Y-, Empty, Z-, Empty, RETRACT, Empty
            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: yHomed ? Style.accent : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                opacity: yHomed ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "↓"
                    font.pixelSize: Style.fontXXLarge
                    font.bold: true
                    color: yHomed ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: yHomed
                    cursorShape: yHomed ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: moveAxis("Y", "-")
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: zHomed ? Style.warning : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                opacity: zHomed ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "Z ↓"
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: zHomed ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: zHomed
                    cursorShape: zHomed ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: moveAxis("Z", "-")
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.error
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "RETRACT"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: extrudeFilament(-currentDistance)
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: true }
        }

        // 底部 - 步长选择
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 4
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Style.spacingMedium
                anchors.rightMargin: Style.spacingMedium
                spacing: Style.spacingSmall

                Repeater {
                    model: [0.1, 1, 5, 10, 25, 50, 100]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: root.currentDistance === modelData ? Style.accent : Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: root.currentDistance === modelData ? Style.accent : Style.divider

                        Label {
                            anchors.centerIn: parent
                            text: modelData >= 1 ? modelData.toFixed(0) : modelData.toFixed(1)
                            font.pixelSize: Style.fontXLarge
                            font.family: Style.fontFamilyMono
                            font.bold: true
                            color: root.currentDistance === modelData ? Style.bgPrimary : Style.textPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentDistance = modelData
                        }
                    }
                }

                Rectangle {
                    width: Style.borderMedium
                    Layout.fillHeight: true
                    Layout.topMargin: Style.spacingSmall
                    Layout.bottomMargin: Style.spacingSmall
                    color: Style.divider
                }

                Label {
                    text: "mm"
                    font.pixelSize: Style.fontLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.textSecondary
                    Layout.preferredWidth: Style.baseUnit * 3
                }
            }
        }
    }

    // 禁用电机确认对话框
    Dialog {
        id: motorsOffDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.5, Style.baseUnit * 20)
        modal: true

        background: Rectangle {
            color: Style.bgCard
            border.width: Style.borderMedium
            border.color: Style.divider
        }

        header: Rectangle {
            width: parent.width
            height: Style.baseUnit * 3
            color: Style.bgSecondary

            Label {
                anchors.centerIn: parent
                text: "DISABLE MOTORS"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
            }
        }

        contentItem: Label {
            text: "Disable all motors?\nThe toolhead may drop!"
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textPrimary
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            padding: Style.spacingLarge
        }

        footer: DialogButtonBox {
            background: Rectangle { color: Style.bgSecondary }

            Button {
                text: "DISABLE"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                background: Rectangle {
                    color: Style.warning
                    border.width: Style.borderThin
                    border.color: Style.divider
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.bgPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "CANCEL"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

                background: Rectangle {
                    color: Style.bgCard
                    border.width: Style.borderThin
                    border.color: Style.divider
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        onAccepted: sendGcode("M18")
    }

    // 辅助函数
    function moveAxis(axis, direction) {
        var gcode = "G91\n"  // 相对定位
        gcode += "G1 " + axis + (direction === "+" ? "" : "-") + currentDistance + " F3000\n"
        gcode += "G90"  // 绝对定位

        sendGcode(gcode)
        console.log("Move:", axis, direction, currentDistance)
    }

    function extrudeFilament(distance) {
        var gcode = "M83\n"  // 挤出机相对定位
        gcode += "G1 E" + distance + " F300\n"
        gcode += "M82"  // 挤出机绝对定位

        sendGcode(gcode)
        console.log("Extrude:", distance)
    }

    function sendGcode(gcode) {
        if (!printer) {
            console.warn("Printer not connected")
            showError("Printer not connected")
            return
        }

        // 使用 WebSocket/JSON-RPC 发送 G-code
        printer.sendGcode(gcode)
        console.log("G-code sent via WebSocket:", gcode)
    }
}
