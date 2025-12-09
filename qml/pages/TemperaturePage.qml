import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// 温度控制页面 (简化版,不含图表)
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
            text: "温度控制"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 温度显示卡片
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Style.spacingLarge
            columnSpacing: Style.spacingLarge

            // 热端温度
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 15
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingMedium

                    Label {
                        text: "热端"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.textPrimary
                    }

                    Label {
                        text: (printer ? printer.hotendTemp.toFixed(1) : "0.0") + "°C"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.error
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "目标: " + (printer ? printer.hotendTarget.toFixed(0) : "0") + "°C"
                        font.pixelSize: Style.fontMedium
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // 预设温度按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacingSmall

                        Repeater {
                            model: [{t:0,n:"关"}, {t:200,n:"PLA"}, {t:240,n:"ABS"}]
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.baseUnit * 4
                                color: Style.error
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.n
                                    font.pixelSize: Style.fontMedium
                                    font.bold: true
                                    color: Style.bgPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (printer) {
                                            printer.sendGcode("M104 S" + modelData.t)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 热床温度
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 15
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingMedium

                    Label {
                        text: "热床"
                        font.pixelSize: Style.fontLarge
                        font.bold: true
                        color: Style.textPrimary
                    }

                    Label {
                        text: (printer ? printer.bedTemp.toFixed(1) : "0.0") + "°C"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.warning
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "目标: " + (printer ? printer.bedTarget.toFixed(0) : "0") + "°C"
                        font.pixelSize: Style.fontMedium
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.spacingSmall

                        Repeater {
                            model: [{t:0,n:"关"}, {t:60,n:"PLA"}, {t:100,n:"ABS"}]
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.baseUnit * 4
                                color: Style.warning
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.n
                                    font.pixelSize: Style.fontMedium
                                    font.bold: true
                                    color: Style.bgPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (printer) {
                                            printer.sendGcode("M140 S" + modelData.t)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
