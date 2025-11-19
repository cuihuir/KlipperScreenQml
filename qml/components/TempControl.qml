import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Metro风格温度控制组件
Rectangle {
    id: control

    property string title: "TEMP"
    property real currentTemp: 0
    property real targetTemp: 0
    property real maxTemp: 300
    property int quickTemp: 200  // 快捷温度值

    signal setTemperature(int temp)
    signal editTemperature()  // 点击温度区域时触发键盘

    color: Style.bgCard
    border.width: Style.borderThin
    border.color: Style.divider

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingMedium

        // 标题
        Label {
            text: title.toUpperCase()
            font.pixelSize: Style.fontSmall
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 2
            color: Style.textSecondary
        }

        // 温度显示 - 当前/目标格式（可点击）
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 3
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: Style.spacingXSmall

                Label {
                    text: currentTemp.toFixed(1) + " / " + targetTemp.toFixed(0)
                    font.pixelSize: Style.fontXXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.getTempColor(currentTemp, maxTemp * 0.7)
                }

                Label {
                    text: "°C"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    color: Style.textSecondary
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: control.editTemperature()
            }

            MouseArea {
                id: tempMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: control.editTemperature()
            }

            // Hover提示
            Rectangle {
                anchors.fill: parent
                color: Style.accent
                opacity: tempMouseArea.containsMouse ? 0.1 : 0
                z: -1

                Behavior on opacity {
                    NumberAnimation { duration: Style.durationFast }
                }
            }
        }

        // 进度指示器 - 简洁横条
        Rectangle {
            Layout.fillWidth: true
            height: Style.baseUnit * 0.5
            color: Style.bgSecondary
            border.width: Style.borderThin
            border.color: Style.divider

            Rectangle {
                width: Math.min(currentTemp / maxTemp, 1.0) * parent.width
                height: parent.height
                color: {
                    var ratio = currentTemp / maxTemp
                    if (ratio > 0.7) return Style.error
                    if (ratio > 0.5) return Style.warning
                    return Style.accent
                }

                Behavior on width {
                    NumberAnimation { duration: Style.durationNormal }
                }
            }
        }

        // 快捷按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            // 快捷温度按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeight
                color: targetTemp === quickTemp ? Style.accent : Style.bgSecondary
                border.width: Style.borderThin
                border.color: targetTemp === quickTemp ? Style.accent : Style.divider

                Label {
                    anchors.centerIn: parent
                    text: quickTemp + "°"
                    font.pixelSize: Style.fontLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: targetTemp === quickTemp ? Style.bgPrimary : Style.textPrimary
                }

                MouseArea {
                    id: quickTempMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: control.setTemperature(quickTemp)
                }

                // Hover效果
                Rectangle {
                    anchors.fill: parent
                    color: Style.accent
                    opacity: quickTempMouseArea.containsMouse && targetTemp !== quickTemp ? 0.1 : 0
                    z: -1

                    Behavior on opacity {
                        NumberAnimation { duration: Style.durationFast }
                    }
                }
            }

            // 冷却按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeight
                color: targetTemp === 0 ? Style.info : Style.bgSecondary
                border.width: Style.borderThin
                border.color: targetTemp === 0 ? Style.info : Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "COOL"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: targetTemp === 0 ? Style.bgPrimary : Style.textPrimary
                }

                MouseArea {
                    id: coolMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: control.setTemperature(0)
                }

                // Hover效果
                Rectangle {
                    anchors.fill: parent
                    color: Style.info
                    opacity: coolMouseArea.containsMouse && targetTemp !== 0 ? 0.1 : 0
                    z: -1

                    Behavior on opacity {
                        NumberAnimation { duration: Style.durationFast }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
