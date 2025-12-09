import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// QWERTY 英文数字键盘组件
Rectangle {
    id: root

    property string inputValue: ""
    property string title: "SEARCH"

    signal confirmed(string value)
    signal cancelled()
    signal textChanged(string value)

    color: Style.bgCard
    border.width: Style.borderThin
    border.color: Style.divider

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingSmall

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

        // 输入框显示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 5
            color: Style.bgSecondary
            border.width: Style.borderMedium
            border.color: Style.accent

            Label {
                anchors.centerIn: parent
                text: inputValue || "..."
                font.pixelSize: Style.fontXLarge
                font.family: Style.fontFamilyMono
                font.bold: true
                color: inputValue ? Style.accent : Style.textDisabled
            }
        }

        // 第一行: 数字键 1-0
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Repeater {
                model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData)
                    }
                }
            }
        }

        // 第二行: Q-P
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Repeater {
                model: ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData.toLowerCase())
                    }
                }
            }
        }

        // 第三行: A-L
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Item { Layout.preferredWidth: Style.baseUnit * 2 }

            Repeater {
                model: ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData.toLowerCase())
                    }
                }
            }

            Item { Layout.preferredWidth: Style.baseUnit * 2 }
        }

        // 第四行: Z-M + 删除
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            // 删除键
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 8
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.warning
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "⌫ DEL"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backspace()
                }
            }

            Repeater {
                model: ["Z", "X", "C", "V", "B", "N", "M"]
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData.toLowerCase())
                    }
                }
            }
        }

        // 第五行: 特殊键
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            // 取消按钮
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 10
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.error
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "✕ 取消"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.cancelled()
                }
            }

            // 空格
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "SPACE"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appendChar(" ")
                }
            }

            // 下划线/连字符
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 6
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "_"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appendChar("_")
                }
            }

            // 连字符
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 6
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "-"
                    font.pixelSize: Style.fontXLarge
                    font.bold: true
                    color: Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appendChar("-")
                }
            }

            // 确认按钮
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 10
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "✓ 确认"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: confirm()
                }
            }
        }
    }

    // 辅助函数
    function appendChar(char) {
        inputValue += char
        root.textChanged(inputValue)
    }

    function backspace() {
        if (inputValue.length > 0) {
            inputValue = inputValue.slice(0, -1)
            root.textChanged(inputValue)
        }
    }

    function confirm() {
        root.confirmed(inputValue)
    }

    function clear() {
        inputValue = ""
        root.textChanged(inputValue)
    }
}
