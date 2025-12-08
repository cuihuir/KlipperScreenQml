import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// 挤出机控制页面 (MovePage 的增强版)
Page {
    id: root
    property var printer: null
    property real extrudeLength: 10
    property real extrudeSpeed: 5

    background: Rectangle {
        color: Style.bgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        Label {
            text: "挤出机控制"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 温度状态
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 8
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            RowLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingLarge
                spacing: Style.spacingLarge

                Label {
                    text: "热端温度:"
                    font.pixelSize: Style.fontLarge
                    color: Style.textSecondary
                }

                Label {
                    text: (printer ? printer.hotendTemp.toFixed(1) : "0.0") + "°C"
                    font.pixelSize: Style.fontXXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: printer && printer.hotendTemp >= 170 ? Style.success : Style.error
                }

                Label {
                    text: "/ " + (printer ? printer.hotendTarget.toFixed(0) : "0") + "°C"
                    font.pixelSize: Style.fontLarge
                    color: Style.textSecondary
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: printer && printer.hotendTemp < 170 ? "⚠️ 温度过低" : "✅ 可以挤出"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: printer && printer.hotendTemp >= 170 ? Style.success : Style.error
                }
            }
        }

        // 挤出控制
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Style.spacingLarge

            // 挤出/退料按钮
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Style.spacingMedium

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.success
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Style.spacingSmall

                        Label {
                            text: "进料"
                            font.pixelSize: Style.fontXXLarge
                            font.bold: true
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "▲"
                            font.pixelSize: Style.fontXXXLarge
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: extrudeLength + " mm"
                            font.pixelSize: Style.fontLarge
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: printer && printer.hotendTemp >= 170
                        onClicked: extrude(extrudeLength)
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.error
                    border.width: Style.borderMedium
                    border.color: Style.divider

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Style.spacingSmall

                        Label {
                            text: "退料"
                            font.pixelSize: Style.fontXXLarge
                            font.bold: true
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "▼"
                            font.pixelSize: Style.fontXXXLarge
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: extrudeLength + " mm"
                            font.pixelSize: Style.fontLarge
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: printer && printer.hotendTemp >= 170
                        onClicked: extrude(-extrudeLength)
                    }
                }
            }

            // 设置面板
            ColumnLayout {
                Layout.preferredWidth: parent.width * 0.4
                Layout.fillHeight: true
                spacing: Style.spacingLarge

                // 挤出长度选择
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgCard
                    border.width: Style.borderThin
                    border.color: Style.divider

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Style.spacingMedium
                        spacing: Style.spacingSmall

                        Label {
                            text: "挤出长度"
                            font.pixelSize: Style.fontMedium
                            font.bold: true
                            color: Style.textPrimary
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            rowSpacing: Style.spacingSmall
                            columnSpacing: Style.spacingSmall

                            Repeater {
                                model: [5, 10, 25, 50, 100, 200]
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Style.baseUnit * 4
                                    color: root.extrudeLength === modelData ? Style.accent : Style.bgSecondary
                                    border.width: Style.borderThin
                                    border.color: Style.divider

                                    Label {
                                        anchors.centerIn: parent
                                        text: modelData + " mm"
                                        font.pixelSize: Style.fontSmall
                                        font.bold: true
                                        color: root.extrudeLength === modelData ? Style.bgPrimary : Style.textPrimary
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.extrudeLength = modelData
                                    }
                                }
                            }
                        }
                    }
                }

                // 挤出速度选择
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgCard
                    border.width: Style.borderThin
                    border.color: Style.divider

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Style.spacingMedium
                        spacing: Style.spacingSmall

                        Label {
                            text: "挤出速度"
                            font.pixelSize: Style.fontMedium
                            font.bold: true
                            color: Style.textPrimary
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 3
                            rowSpacing: Style.spacingSmall
                            columnSpacing: Style.spacingSmall

                            Repeater {
                                model: [1, 3, 5, 10, 15, 20]
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Style.baseUnit * 4
                                    color: root.extrudeSpeed === modelData ? Style.info : Style.bgSecondary
                                    border.width: Style.borderThin
                                    border.color: Style.divider

                                    Label {
                                        anchors.centerIn: parent
                                        text: modelData + " mm/s"
                                        font.pixelSize: Style.fontSmall
                                        font.bold: true
                                        color: root.extrudeSpeed === modelData ? Style.bgPrimary : Style.textPrimary
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.extrudeSpeed = modelData
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function extrude(length) {
        if (!printer) return
        if (printer.hotendTemp < 170) {
            console.warn("Temperature too low for extrusion")
            return
        }

        var feedrate = Math.round(extrudeSpeed * 60)
        var gcode = "M83\nG1 E" + length.toFixed(1) + " F" + feedrate + "\nM82"
        printer.sendGcode(gcode)
        console.log("Extruding:", length, "mm at", extrudeSpeed, "mm/s")
    }
}
