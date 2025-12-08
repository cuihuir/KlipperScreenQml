import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// 热床调平页面
Page {
    id: root
    property var printer: null

    background: Rectangle {
        color: Style.bgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        Label {
            text: "热床调平"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 调平点位图
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            GridLayout {
                anchors.centerIn: parent
                columns: 3
                rows: 3
                columnSpacing: Style.baseUnit * 5
                rowSpacing: Style.baseUnit * 5

                // 左上
                Rectangle {
                    width: Style.baseUnit * 8
                    height: Style.baseUnit * 8
                    color: Style.accent
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: "左上\n1"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: moveToCorner(0, 0)
                    }
                }

                Item { width: Style.baseUnit * 8; height: Style.baseUnit * 8 }

                // 右上
                Rectangle {
                    width: Style.baseUnit * 8
                    height: Style.baseUnit * 8
                    color: Style.accent
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: "右上\n2"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: moveToCorner(1, 0)
                    }
                }

                Item { width: Style.baseUnit * 8; height: Style.baseUnit * 8 }

                // 中心
                Rectangle {
                    width: Style.baseUnit * 8
                    height: Style.baseUnit * 8
                    color: Style.info
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: "中心\n5"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: moveToCenter()
                    }
                }

                Item { width: Style.baseUnit * 8; height: Style.baseUnit * 8 }

                // 左下
                Rectangle {
                    width: Style.baseUnit * 8
                    height: Style.baseUnit * 8
                    color: Style.accent
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: "左下\n3"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: moveToCorner(0, 1)
                    }
                }

                Item { width: Style.baseUnit * 8; height: Style.baseUnit * 8 }

                // 右下
                Rectangle {
                    width: Style.baseUnit * 8
                    height: Style.baseUnit * 8
                    color: Style.accent
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: "右下\n4"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: moveToCorner(1, 1)
                    }
                }
            }
        }

        // 控制按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingLarge

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: Style.info
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "归零"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (printer) {
                            printer.sendGcode("G28")
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "自动调平"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (printer) {
                            printer.sendGcode("BED_MESH_CALIBRATE")
                        }
                    }
                }
            }
        }
    }

    function moveToCorner(x, y) {
        if (!printer) return
        // 移动到床角位置 (假设床尺寸 200x200)
        var xPos = x === 0 ? 20 : 180
        var yPos = y === 0 ? 20 : 180
        var gcode = "G28\nG1 Z10 F600\nG1 X" + xPos + " Y" + yPos + " F3000\nG1 Z0.2 F600"
        printer.sendGcode(gcode)
        console.log("Moving to corner:", xPos, yPos)
    }

    function moveToCenter() {
        if (!printer) return
        var gcode = "G28\nG1 Z10 F600\nG1 X100 Y100 F3000\nG1 Z0.2 F600"
        printer.sendGcode(gcode)
        console.log("Moving to center")
    }
}
