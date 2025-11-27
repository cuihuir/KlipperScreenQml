import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * LedWidget - LED 控制 Widget
 *
 * 显示单个 LED 的当前状态（开/关）和亮度百分比。
 * 当前为占位符实现，显示静态"关闭"状态。
 *
 * 使用示例:
 *   LedWidget {
 *       widgetId: "led_chamber"
 *       ledName: "仓灯"
 *       ledBrightness: 0.0
 *   }
 */
HomeWidget {
    id: root

    // ===== 公共属性 =====

    /**
     * LED 名称（如 "仓灯", "状态指示灯"）
     */
    property string ledName: "LED"

    /**
     * LED 亮度（0.0-1.0，0 表示关闭）
     */
    property real ledBrightness: 0.0

    // ===== 基类属性配置 =====
    title: ledName
    widgetState: "idle"
    isInteractive: true

    // ===== 内容区域 =====
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingSmall

        // LED 图标（发光效果）
        Rectangle {
            width: Style.baseUnit * 6
            height: Style.baseUnit * 6
            radius: width / 2
            color: root.ledBrightness > 0 ? Style.accent : Style.bgCard
            border.width: Style.borderMedium
            border.color: root.ledBrightness > 0 ? Style.accent : Style.border
            Layout.alignment: Qt.AlignHCenter

            // 发光效果（仅在 LED 开启时）
            Rectangle {
                visible: root.ledBrightness > 0
                anchors.centerIn: parent
                width: parent.width * 1.5
                height: parent.height * 1.5
                radius: width / 2
                color: Qt.rgba(Style.accent.r, Style.accent.g, Style.accent.b, root.ledBrightness * 0.3)
                opacity: 0.6

                // 呼吸动画
                SequentialAnimation {
                    running: root.ledBrightness > 0
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: parent
                        property: "opacity"
                        from: 0.4
                        to: 0.8
                        duration: 1000
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        target: parent
                        property: "opacity"
                        from: 0.8
                        to: 0.4
                        duration: 1000
                        easing.type: Easing.InOutSine
                    }
                }
            }

            // 灯泡图标
            Text {
                anchors.centerIn: parent
                text: "💡"
                font.pixelSize: Style.fontXLarge
                opacity: root.ledBrightness > 0 ? 1.0 : 0.3
            }
        }

        // 状态文本
        Text {
            text: root.ledBrightness > 0 ? (root.ledBrightness * 100).toFixed(0) + "%" : "关闭"
            font.pixelSize: Style.fontLarge
            font.family: Style.fontFamilyMono
            font.bold: true
            color: root.ledBrightness > 0 ? Style.textPrimary : Style.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ===== 点击事件（未来实现 LED 亮度调节） =====
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("LedWidget clicked:", root.ledName, "brightness:", root.ledBrightness)
            // TODO: Phase 5 - 打开 LED 亮度调节对话框
        }
    }
}
