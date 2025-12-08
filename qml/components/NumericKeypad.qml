import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "." as Components

// 数字键盘组件
Rectangle {
    id: root

    property string inputValue: ""
    property string title: "ENTER VALUE"
    property int maxLength: 3

    signal confirmed(string value)
    signal cancelled()

    color: Style.bgCard
    border.width: Style.borderThin
    border.color: Style.divider

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingMedium

        // 标题
        Label {
            Layout.fillWidth: true
            text: title
            font.pixelSize: Style.fontMedium
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 2
            color: Style.textPrimary
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: Style.borderThin
            color: Style.divider
        }

        // 整体键盘布局 (5列x4行)
        // 布局: [输入框__________][占位符][冷却]
        //       [1][2][3][删除][取消]
        //       [4][5][6][ . ][确认↑]
        //       [7][8][9][ 0 ][确认↓]
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 5
            rows: 4
            rowSpacing: Style.spacingMedium
            columnSpacing: Style.spacingMedium

            // ===== 第零行：输入显示 =====
            // 输入框 (占据 3 列)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 5
                Layout.columnSpan: 3
                color: Style.bgSecondary
                border.width: Style.borderMedium
                border.color: Style.accent

                Label {
                    anchors.centerIn: parent
                    text: inputValue || "---"
                    font.pixelSize: Style.fontXXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: inputValue ? Style.accent : Style.textDisabled
                }
            }

            // 占位框
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 5
                color: Style.bgPrimary
                border.width: Style.borderThin
                border.color: Style.divider
                opacity: 0.3
            }

            // 冷却按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 5
                color: Style.info
                border.width: Style.borderMedium
                border.color: Style.divider

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Label {
                        text: "❄"
                        font.pixelSize: Style.fontMedium
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "冷却"
                        font.pixelSize: Style.fontXSmall
                        font.bold: true
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        inputValue = "0"
                        confirm()
                    }
                }
            }

            // ===== 第一行 =====
            // 数字 1-3
            Repeater {
                model: 3
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgSecondary
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: index + 1
                        font.pixelSize: Style.fontXXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendDigit(index + 1)
                    }
                }
            }

            // 删除键
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.warning
                border.width: Style.borderMedium
                border.color: Style.divider

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Components.ThemedIcon {
                        iconName: "arrow-left"
                        iconSize: Style.fontLarge
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "删除"
                        font.pixelSize: Style.fontXSmall
                        font.bold: true
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backspace()
                }
            }

            // 取消按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.error
                border.width: Style.borderMedium
                border.color: Style.divider

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Label {
                        text: "✕"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "取消"
                        font.pixelSize: Style.fontXSmall
                        font.bold: true
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.cancelled()
                }
            }

            // ===== 第二行 =====
            // 数字 4-6
            Repeater {
                model: 3
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgSecondary
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: index + 4
                        font.pixelSize: Style.fontXXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendDigit(index + 4)
                    }
                }
            }

            // 小数点
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgSecondary
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "."
                    font.pixelSize: Style.fontXXXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (inputValue.indexOf(".") === -1 && inputValue.length > 0) {
                            inputValue += "."
                        }
                    }
                }
            }

            // 确认按钮 (rowSpan=2)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rowSpan: 2
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingSmall

                    Components.ThemedIcon {
                        iconName: "complete"
                        iconSize: Style.fontXXLarge
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "确认"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: confirm()
                }
            }

            // ===== 第三行 =====
            // 数字 7-9
            Repeater {
                model: 3
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgSecondary
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: index + 7
                        font.pixelSize: Style.fontXXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendDigit(index + 7)
                    }
                }
            }

            // 数字 0
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgSecondary
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "0"
                    font.pixelSize: Style.fontXXXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appendDigit(0)
                }
            }

            // 确认按钮占据这个位置 (rowSpan=2)
        }
    }

    // 辅助函数
    function appendDigit(digit) {
        if (inputValue.length < maxLength) {
            inputValue += digit.toString()
        }
    }

    function backspace() {
        if (inputValue.length > 0) {
            inputValue = inputValue.slice(0, -1)
        }
    }

    function confirm() {
        if (inputValue.length > 0) {
            root.confirmed(inputValue)
        }
    }

    function clear() {
        inputValue = ""
    }
}
