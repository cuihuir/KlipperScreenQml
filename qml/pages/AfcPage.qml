import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Metro风格 AFC 多色管理页
Page {
    id: root
    property var printer: null
    property var app: null

    signal showError(string message)

    background: Rectangle {
        color: Style.bgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // 顶部标题栏
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            Label {
                text: "AFC MANAGEMENT"
                font.pixelSize: Style.fontLarge
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
            }

            Item { Layout.fillWidth: true }

            // 状态指示
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 10
                Layout.preferredHeight: Style.buttonHeightSmall
                color: Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "IDLE: NONE"
                    font.pixelSize: Style.fontSmall
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.textSecondary
                }
            }
        }

        // Extruder Tools 部分
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 8
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingMedium
                spacing: Style.spacingMedium

                // 标题
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Extruder Tools"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 1
                        color: Style.textPrimary
                    }

                    Item { Layout.fillWidth: true }

                    ThemedIcon {
                        iconName: "arrow-down"
                        iconSize: Style.fontSmall
                        opacity: 0.6
                    }
                }

                // Extruder 状态
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingLarge

                    // 指示点
                    Rectangle {
                        width: Style.baseUnit
                        height: Style.baseUnit
                        radius: width / 2
                        color: Style.error
                    }

                    Label {
                        text: "extruder"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textPrimary
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        text: "Buffer Not Active"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        text: "Idle: NONE"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                }
            }
        }

        // Turtle 1 部分 (Hub)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingMedium
                spacing: Style.spacingMedium

                // 标题栏
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "🐢"
                        font.pixelSize: Style.fontLarge
                    }

                    Label {
                        text: "Turtle 1"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 1
                        color: Style.textPrimary
                    }

                    Rectangle {
                        Layout.preferredWidth: Style.baseUnit * 4
                        Layout.preferredHeight: Style.baseUnit * 1.5
                        color: Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.success

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Style.spacingXSmall

                            Label {
                                text: "Hub"
                                font.pixelSize: Style.fontXSmall
                                font.family: Style.fontFamily
                                color: Style.textPrimary
                            }

                            Rectangle {
                                width: Style.baseUnit * 0.6
                                height: Style.baseUnit * 0.6
                                radius: width / 2
                                color: Style.success
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ThemedIcon {
                        iconName: "arrow-down"
                        iconSize: Style.fontSmall
                        opacity: 0.6
                    }
                }

                // Lanes 网格
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 4
                    rowSpacing: Style.spacingMedium
                    columnSpacing: Style.spacingMedium

                    // Lane 1
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.divider

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Style.spacingMedium
                            spacing: Style.spacingSmall

                            Label {
                                text: "lane1"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                color: Style.warning
                            }

                            Label {
                                text: "T0"
                                font.pixelSize: Style.fontMedium
                                font.family: Style.fontFamilyMono
                                font.bold: true
                                color: Style.textPrimary
                                Layout.alignment: Qt.AlignRight
                            }

                            Item { Layout.fillHeight: true }

                            Label {
                                text: "Filament not\ndetected at the\nextruder"
                                font.pixelSize: Style.fontXSmall
                                font.family: Style.fontFamily
                                color: Style.textSecondary
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Lane 2
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.divider

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Style.spacingMedium
                            spacing: Style.spacingSmall

                            Label {
                                text: "lane2"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                color: Style.warning
                            }

                            Label {
                                text: "T1"
                                font.pixelSize: Style.fontMedium
                                font.family: Style.fontFamilyMono
                                font.bold: true
                                color: Style.textPrimary
                                Layout.alignment: Qt.AlignRight
                            }

                            Item { Layout.fillHeight: true }

                            Label {
                                text: "Filament not\ndetected at the\nextruder"
                                font.pixelSize: Style.fontXSmall
                                font.family: Style.fontFamily
                                color: Style.textSecondary
                                wrapMode: Text.WordWrap
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Lane 3
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.success

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Style.spacingMedium
                            spacing: Style.spacingSmall

                            Label {
                                text: "lane3"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                color: Style.success
                            }

                            Label {
                                text: "T2"
                                font.pixelSize: Style.fontMedium
                                font.family: Style.fontFamilyMono
                                font.bold: true
                                color: Style.textPrimary
                                Layout.alignment: Qt.AlignRight
                            }

                            // 料卷图标
                            Label {
                                text: "🟠"
                                font.pixelSize: Style.baseUnit * 3
                                Layout.alignment: Qt.AlignHCenter
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: "NONE"
                                    font.pixelSize: Style.fontSmall
                                    font.family: Style.fontFamilyMono
                                    font.bold: true
                                    color: Style.textPrimary
                                }

                                Label {
                                    text: "∞"
                                    font.pixelSize: Style.fontMedium
                                    color: Style.error
                                }

                                Item { Layout.fillWidth: true }

                                Label {
                                    text: "0 g"
                                    font.pixelSize: Style.fontXSmall
                                    font.family: Style.fontFamily
                                    color: Style.textSecondary
                                }
                            }
                        }
                    }

                    // Lane 4
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Style.bgSecondary
                        border.width: Style.borderThin
                        border.color: Style.divider

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Style.spacingMedium
                            spacing: Style.spacingSmall

                            Label {
                                text: "lane4"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                color: Style.error
                            }

                            Label {
                                text: "T3"
                                font.pixelSize: Style.fontMedium
                                font.family: Style.fontFamilyMono
                                font.bold: true
                                color: Style.textPrimary
                                Layout.alignment: Qt.AlignRight
                            }

                            Item { Layout.fillHeight: true }

                            Label {
                                text: "Lane Empty"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                color: Style.textSecondary
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
