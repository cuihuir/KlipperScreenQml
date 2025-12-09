import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// Z 轴校准页面
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
            text: "Z 轴校准"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 当前 Z 偏移显示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 10
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.spacingMedium

                Label {
                    text: "当前 Z 偏移"
                    font.pixelSize: Style.fontLarge
                    color: Style.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: (printer ? printer.zOffset.toFixed(3) : "0.000") + " mm"
                    font.pixelSize: Style.fontXXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.warning
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // 调整按钮网格
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: Style.spacingMedium
            columnSpacing: Style.spacingMedium

            // 大步进 +
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "+ 0.1 mm"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: adjustZOffset(0.1)
                }
            }

            // 中步进 +
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "+ 0.05 mm"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: adjustZOffset(0.05)
                }
            }

            // 小步进 +
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "+ 0.01 mm"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: adjustZOffset(0.01)
                }
            }

            // 大步进 -
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.error
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "- 0.1 mm"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: adjustZOffset(-0.1)
                }
            }

            // 中步进 -
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.error
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "- 0.05 mm"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: adjustZOffset(-0.05)
                }
            }

            // 小步进 -
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.error
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "- 0.01 mm"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: adjustZOffset(-0.01)
                }
            }
        }

        // 保存和测试按钮
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
                    text: "测试打印"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: testPrint()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: Style.accent
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "保存设置"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: saveZOffset()
                }
            }
        }
    }

    function adjustZOffset(delta) {
        if (!printer) return
        var gcode = "SET_GCODE_OFFSET Z_ADJUST=" + delta.toFixed(3)
        printer.sendGcode(gcode)
        console.log("Z offset adjusted by:", delta)
    }

    function saveZOffset() {
        if (!printer) return
        printer.sendGcode("Z_OFFSET_APPLY_ENDSTOP")
        printer.sendGcode("SAVE_CONFIG")
        console.log("Z offset saved")
    }

    function testPrint() {
        if (!printer) return
        // 打印一个小的测试方块
        var gcode = "G28\nG1 Z0.2 F600\nG1 X50 Y50 F3000\nG91\nG1 X10 E10 F300\nG1 Y10 E10\nG1 X-10 E10\nG1 Y-10 E10\nG90"
        printer.sendGcode(gcode)
        console.log("Test print started")
    }
}
