import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// 安全的时间格式化函数，避免锁屏乱码
function formatTimeSafe(date) {
    try {
        var hours = date.getHours().toString().padStart(2, '0')
        var minutes = date.getMinutes().toString().padStart(2, '0')
        return hours + ":" + minutes
    } catch (e) {
        console.error("Time formatting error:", e)
        return "--:--"
    }
}

// Metro风格状态栏 - 机场指示牌风格
Rectangle {
    id: root

    property var printer: null

    height: Style.baseUnit * 2.5
    color: Style.bgPrimary

    // 顶部分隔线
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: Style.borderThin
        color: Style.divider
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.spacingLarge
        anchors.rightMargin: Style.spacingLarge
        spacing: Style.spacingLarge

        // 连接状态
        RowLayout {
            spacing: Style.spacingSmall

            Rectangle {
                width: Style.fontSmall
                height: Style.fontSmall
                radius: Style.fontSmall / 2
                color: printer && printer.isConnected ? Style.connected : Style.disconnected

                SequentialAnimation on opacity {
                    running: printer && !printer.isConnected
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                    NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                }
            }

            Label {
                text: printer && printer.isConnected ? "ONLINE" : "OFFLINE"
                font.pixelSize: Style.fontSmall
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 1
                color: Style.textSecondary
            }
        }

        Rectangle {
            width: Style.borderThin
            Layout.fillHeight: true
            Layout.topMargin: Style.spacingSmall
            Layout.bottomMargin: Style.spacingSmall
            color: Style.divider
        }

        // 挤出机温度
        RowLayout {
            spacing: Style.spacingSmall

            Label {
                text: "EXTRUDER"
                font.pixelSize: Style.fontSmall
                font.family: Style.fontFamily
                font.letterSpacing: 1
                color: Style.textSecondary
            }

            Label {
                text: printer ? printer.extruderTemp.toFixed(1) : "0.0"
                font.pixelSize: Style.fontNormal
                font.family: Style.fontFamilyMono
                font.bold: true
                color: Style.getTempColor(
                    printer ? printer.extruderTemp : 0,
                    200
                )
            }

            Label {
                text: "/"
                font.pixelSize: Style.fontSmall
                color: Style.textDisabled
            }

            Label {
                text: printer ? printer.extruderTarget.toFixed(0) : "0"
                font.pixelSize: Style.fontSmall
                font.family: Style.fontFamilyMono
                color: Style.textSecondary
            }

            Label {
                text: "°C"
                font.pixelSize: Style.fontXSmall
                color: Style.textSecondary
            }
        }

        Rectangle {
            width: Style.borderThin
            Layout.fillHeight: true
            Layout.topMargin: Style.spacingSmall
            Layout.bottomMargin: Style.spacingSmall
            color: Style.divider
        }

        // 热床温度
        RowLayout {
            spacing: Style.spacingSmall

            Label {
                text: "BED"
                font.pixelSize: Style.fontSmall
                font.family: Style.fontFamily
                font.letterSpacing: 1
                color: Style.textSecondary
            }

            Label {
                text: printer ? printer.bedTemp.toFixed(1) : "0.0"
                font.pixelSize: Style.fontNormal
                font.family: Style.fontFamilyMono
                font.bold: true
                color: Style.getTempColor(
                    printer ? printer.bedTemp : 0,
                    80
                )
            }

            Label {
                text: "/"
                font.pixelSize: Style.fontSmall
                color: Style.textDisabled
            }

            Label {
                text: printer ? printer.bedTarget.toFixed(0) : "0"
                font.pixelSize: Style.fontSmall
                font.family: Style.fontFamilyMono
                color: Style.textSecondary
            }

            Label {
                text: "°C"
                font.pixelSize: Style.fontXSmall
                color: Style.textSecondary
            }
        }

        Item { Layout.fillWidth: true }

        // 打印进度（如果正在打印）
        RowLayout {
            spacing: Style.spacingSmall
            visible: printer && printer.printProgress > 0

            Label {
                text: "PROGRESS"
                font.pixelSize: Style.fontSmall
                font.family: Style.fontFamily
                font.letterSpacing: 1
                color: Style.textSecondary
            }

            Label {
                text: printer ? printer.printProgress.toFixed(1) + "%" : "0.0%"
                font.pixelSize: Style.fontNormal
                font.family: Style.fontFamilyMono
                font.bold: true
                color: Style.accent
            }
        }

        Rectangle {
            width: Style.borderThin
            Layout.fillHeight: true
            Layout.topMargin: Style.spacingSmall
            Layout.bottomMargin: Style.spacingSmall
            color: Style.divider
            visible: printer && printer.printProgress > 0
        }

        // 当前时间 - 性能优化：仅显示 HH:mm
        Label {
            id: timeLabel
            font.pixelSize: Style.fontSmall
            font.family: Style.fontFamilyMono
            font.letterSpacing: 1
            color: Style.textSecondary

            Timer {
                interval: 60000  // 每分钟更新一次，减少 CPU 占用
                running: true
                repeat: true
                onTriggered: {
                    var now = new Date()
                    timeLabel.text = formatTimeSafe(now)
                }
            }

            Component.onCompleted: {
                var now = new Date()
                text = formatTimeSafe(now)
            }
        }
    }
}
