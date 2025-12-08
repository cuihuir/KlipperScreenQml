import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// 校准菜单页面
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
            text: "校准菜单"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 校准功能网格 (2x2)
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: Style.spacingLarge
            columnSpacing: Style.spacingLarge

            // 热床调平
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderMedium
                border.color: Style.accent

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingMedium

                    Components.ThemedIcon {
                        iconName: "bed-level"
                        iconSize: Style.fontXXXLarge * 1.5
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "热床调平"
                        font.pixelSize: Style.fontXLarge
                        font.bold: true
                        color: Style.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "手动调节热床四角"
                        font.pixelSize: Style.fontSmall
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navigateTo("bed_level")
                }
            }

            // Z轴校准
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderMedium
                border.color: Style.warning

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingMedium

                    Components.ThemedIcon {
                        iconName: "arrow-up"
                        iconSize: Style.fontXXXLarge * 1.5
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Z 轴校准"
                        font.pixelSize: Style.fontXLarge
                        font.bold: true
                        color: Style.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "调整 Z 轴偏移量"
                        font.pixelSize: Style.fontSmall
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navigateTo("zcalibrate")
                }
            }

            // 网格调平
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderMedium
                border.color: Style.info

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingMedium

                    Components.ThemedIcon {
                        iconName: "grid"
                        iconSize: Style.fontXXXLarge * 1.5
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "网格调平"
                        font.pixelSize: Style.fontXLarge
                        font.bold: true
                        color: Style.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "床网格测量和可视化"
                        font.pixelSize: Style.fontSmall
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navigateTo("bed_mesh")
                }
            }

            // 振动补偿
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderMedium
                border.color: Style.success

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingMedium

                    Components.ThemedIcon {
                        iconName: "settings"
                        iconSize: Style.fontXXXLarge * 1.5
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "振动补偿"
                        font.pixelSize: Style.fontXLarge
                        font.bold: true
                        color: Style.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Input Shaper 配置"
                        font.pixelSize: Style.fontSmall
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navigateTo("input_shaper")
                }
            }
        }
    }

    function navigateTo(pageId) {
        var appWindow = root.Window.window
        if (appWindow && appWindow.pageRegistry) {
            appWindow.pageRegistry.navigateTo(pageId)
        } else {
            console.error("Unable to navigate: pageRegistry not found")
        }
    }
}
