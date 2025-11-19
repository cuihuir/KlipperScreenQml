import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

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

        // 输入显示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 4
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

        // 数字键盘网格
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: Style.spacingSmall
            columnSpacing: Style.spacingSmall

            // 数字 1-9
            Repeater {
                model: 9

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    // Hover效果
                    Rectangle {
                        anchors.fill: parent
                        color: Style.accent
                        opacity: mouseArea.containsMouse ? 0.2 : 0
                        z: -1

                        Behavior on opacity {
                            NumberAnimation { duration: Style.durationFast }
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: index + 1
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
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
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: Style.fontXXLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backspace()
                }
            }

            // 数字 0
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider

                // Hover效果
                Rectangle {
                    anchors.fill: parent
                    color: Style.accent
                    opacity: zeroMouseArea.containsMouse ? 0.2 : 0
                    z: -1

                    Behavior on opacity {
                        NumberAnimation { duration: Style.durationFast }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: "0"
                    font.pixelSize: Style.fontXXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.textPrimary
                }

                MouseArea {
                    id: zeroMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appendDigit(0)
                }
            }

            // 确认键
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.success
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: Style.fontXXLarge
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

        // 取消按钮
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.buttonHeight
            color: Style.error
            border.width: Style.borderThin
            border.color: Style.divider

            Label {
                anchors.centerIn: parent
                text: "CANCEL"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.cancelled()
            }
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
