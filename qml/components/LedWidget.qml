import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * LedWidget - LED 控制 Widget
 *
 * 显示单个 LED 的当前状态（开/关）和亮度百分比。
 * 提供滑块控制 LED 亮度。
 *
 * 使用示例:
 *   LedWidget {
 *       widgetId: "led_chamber"
 *       ledName: "仓灯"
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
     * LED 亮度（0.0-1.0，0 表示关闭） - 内部属性，由数据绑定更新
     */
    property real ledBrightness: 0.0

    /**
     * LED 是否开启
     */
    property bool ledOn: ledBrightness > 0

    // ===== 基类属性配置 =====
    title: ledName
    widgetState: "idle"
    isInteractive: true

    // ===== 数据绑定：连接 MoonrakerClient =====
    Connections {
        target: app ? app.printer : null

        function onLedStateChanged(led_name, is_on, brightness) {
            root.ledBrightness = brightness
        }
    }

    // ===== 内容区域 =====
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingMedium

        // 顶部：LED 图标 + 亮度百分比
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 5
            spacing: Style.spacingMedium

            // LED 灯泡图标（发光效果）
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 5
                Layout.preferredHeight: Style.baseUnit * 5
                radius: width / 2
                color: root.ledOn ? Qt.rgba(1, 0.9, 0.3, root.ledBrightness) : Style.bgCard
                border.width: Style.borderMedium
                border.color: root.ledOn ? Style.accent : Style.border

                // 发光效果
                Rectangle {
                    visible: root.ledOn
                    anchors.centerIn: parent
                    width: parent.width * 1.3
                    height: parent.height * 1.3
                    radius: width / 2
                    color: Qt.rgba(1, 0.9, 0.3, root.ledBrightness * 0.3)
                    opacity: 0.6
                }

                Text {
                    anchors.centerIn: parent
                    text: "💡"
                    font.pixelSize: Style.fontLarge
                    opacity: root.ledOn ? 1.0 : 0.3
                }
            }

            // 亮度百分比
            Text {
                text: root.ledOn ? Math.round(root.ledBrightness * 100) + "%" : "关闭"
                font.pixelSize: Style.fontXLarge
                font.family: Style.fontFamilyMono
                font.bold: true
                color: root.ledOn ? Style.textPrimary : Style.textSecondary
                Layout.fillWidth: true
            }
        }

        // 中间：亮度滑块
        Slider {
            id: ledSlider
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            value: root.ledBrightness
            stepSize: 0.05

            onMoved: {
                // 滑块拖动时实时更新
                if (app && app.printer) {
                    app.printer.setLedBrightness(root.ledName, value)
                }
            }

            background: Rectangle {
                x: ledSlider.leftPadding
                y: ledSlider.topPadding + ledSlider.availableHeight / 2 - height / 2
                width: ledSlider.availableWidth
                height: Style.borderMedium
                radius: Style.radiusSmall
                color: Style.bgSecondary

                Rectangle {
                    width: ledSlider.visualPosition * parent.width
                    height: parent.height
                    color: Style.accent
                    radius: Style.radiusSmall
                }
            }

            handle: Rectangle {
                x: ledSlider.leftPadding + ledSlider.visualPosition * (ledSlider.availableWidth - width)
                y: ledSlider.topPadding + ledSlider.availableHeight / 2 - height / 2
                width: Style.baseUnit * 2
                height: Style.baseUnit * 2
                radius: width / 2
                color: ledSlider.pressed ? Qt.lighter(Style.accent, 1.2) : Style.accent
                border.width: Style.borderThin
                border.color: Qt.lighter(Style.accent, 1.3)
            }
        }

        // 底部：开关按钮
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.buttonHeight
            color: root.ledOn ? Style.warning : Style.bgSecondary
            border.width: Style.borderThin
            border.color: Style.border
            radius: Style.radiusSmall

            Text {
                anchors.centerIn: parent
                text: root.ledOn ? "关闭灯光" : "开启灯光"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                color: root.ledOn ? Style.bgPrimary : Style.textPrimary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (app && app.printer) {
                        app.printer.setLedOnOff(root.ledName, !root.ledOn)
                    }
                }
            }
        }
    }
}
