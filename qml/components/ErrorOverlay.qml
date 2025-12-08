import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// 全屏 Klipper 错误显示遮罩 (Metro 风格)
Rectangle {
    id: overlay
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.95)  // 半透明黑色背景
    visible: false
    z: 1000  // 确保在最上层

    property string errorMessage: ""
    property var printer: null

    signal dismissed()

    // 淡入淡出动画
    opacity: 0
    Behavior on opacity {
        NumberAnimation { duration: Style.durationNormal }
    }

    onVisibleChanged: {
        opacity = visible ? 1 : 0
    }

    MouseArea {
        // 阻止点击穿透
        anchors.fill: parent
        onClicked: {}  // 吞掉点击事件
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, Style.baseUnit * 40)
        spacing: Style.spacingLarge

        // 错误图标
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "⚠"
            font.pixelSize: Style.baseUnit * 6
            color: Style.error
        }

        // 标题
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "KLIPPER ERROR"
            font.pixelSize: Style.fontXLarge
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 3
            color: Style.error
        }

        // 错误消息区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 15
            color: Style.bgCard
            border.width: Style.borderMedium
            border.color: Style.error

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // 左侧滚动按钮区域
                ColumnLayout {
                    Layout.preferredWidth: Style.baseUnit * 3
                    Layout.fillHeight: true
                    spacing: Style.spacingSmall

                    Item { Layout.fillHeight: true }

                    // 向上翻页按钮
                    Rectangle {
                        Layout.preferredWidth: Style.baseUnit * 2.5
                        Layout.preferredHeight: Style.baseUnit * 2.5
                        Layout.alignment: Qt.AlignHCenter
                        color: scrollView.ScrollBar.vertical.position > 0 ? Style.accent : Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.divider

                        ThemedIcon {
                            anchors.centerIn: parent
                            iconName: "arrow-up"
                            iconSize: Style.fontMedium
                            opacity: scrollView.ScrollBar.vertical.position > 0 ? 1.0 : 0.3
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: scrollView.ScrollBar.vertical.position > 0
                            onClicked: {
                                var newPos = Math.max(0, scrollView.ScrollBar.vertical.position - 0.2)
                                scrollView.ScrollBar.vertical.position = newPos
                            }
                        }
                    }

                    // 向下翻页按钮
                    Rectangle {
                        Layout.preferredWidth: Style.baseUnit * 2.5
                        Layout.preferredHeight: Style.baseUnit * 2.5
                        Layout.alignment: Qt.AlignHCenter
                        color: (scrollView.ScrollBar.vertical.position + scrollView.ScrollBar.vertical.size) < 1.0 ? Style.accent : Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.divider

                        ThemedIcon {
                            anchors.centerIn: parent
                            iconName: "arrow-down"
                            iconSize: Style.fontMedium
                            opacity: (scrollView.ScrollBar.vertical.position + scrollView.ScrollBar.vertical.size) < 1.0 ? 1.0 : 0.3
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: (scrollView.ScrollBar.vertical.position + scrollView.ScrollBar.vertical.size) < 1.0
                            onClicked: {
                                var newPos = Math.min(1.0 - scrollView.ScrollBar.vertical.size, scrollView.ScrollBar.vertical.position + 0.2)
                                scrollView.ScrollBar.vertical.position = newPos
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                // 文本滚动区域
                ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: Style.spacingMedium
                    clip: true

                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Label {
                        text: errorMessage
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                        wrapMode: Text.WordWrap
                        width: scrollView.width - Style.spacingMedium * 2
                    }
                }
            }
        }

        // 操作按钮
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.spacingMedium

            // RETRY 按钮
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 10
                Layout.preferredHeight: Style.baseUnit * 3
                color: Style.info
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "RETRY"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (printer) {
                            printer.clearError()
                            overlay.visible = false
                            dismissed()
                        }
                    }
                }
            }

            // RESTART KLIPPER FIRMWARE 按钮
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 18
                Layout.preferredHeight: Style.baseUnit * 3
                color: Style.error
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "RESTART KLIPPER FIRMWARE"
                    font.pixelSize: Style.fontSmall
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (printer) {
                            printer.firmwareRestart()
                            overlay.visible = false
                            dismissed()
                        }
                    }
                }
            }
        }

        // 提示文字
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Klipper has encountered an error.\nClick RETRY to dismiss, or RESTART KLIPPER FIRMWARE to reload the configuration."
            font.pixelSize: Style.fontSmall
            font.family: Style.fontFamily
            color: Style.textSecondary
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.preferredWidth: parent.width
        }
    }

    function show(message) {
        errorMessage = message
        visible = true
    }

    function hide() {
        visible = false
    }
}
