import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * FanWidget - 风扇控制 Widget
 *
 * 显示单个风扇的当前状态（开/关）和速度百分比。
 * 提供滑块控制风扇速度。
 *
 * 使用示例:
 *   FanWidget {
 *       widgetId: "fan_part_cooling"
 *       fanName: "打印冷却"
 *   }
 */
HomeWidget {
    id: root

    // ===== 公共属性 =====

    /**
     * 风扇名称（如 "打印冷却", "电子冷却"）
     */
    property string fanName: "风扇"

    /**
     * 风扇速度（0.0-1.0，0 表示关闭） - 内部属性，由数据绑定更新
     */
    property real fanSpeed: 0.0

    /**
     * 风扇是否开启
     */
    property bool fanOn: fanSpeed > 0

    // ===== 基类属性配置 =====
    title: fanName
    widgetState: "idle"
    isInteractive: true

    // ===== 数据绑定：连接 MoonrakerClient =====
    Connections {
        target: app ? app.printer : null

        function onFanStateChanged(fan_name, is_on, speed) {
            root.fanSpeed = speed
        }
    }

    // ===== 内容区域 =====
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingMedium

        // 顶部：风扇图标 + 速度百分比
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 5
            spacing: Style.spacingMedium

            // 风扇图标（旋转动画） - 使用 KlipperScreen SVG
            ThemedIcon {
                iconName: root.fanOn ? "fan-on" : "fan"
                iconSize: Style.fontXXLarge
                Layout.alignment: Qt.AlignVCenter
                opacity: root.fanOn ? 1.0 : 0.5

                // 旋转动画
                RotationAnimator {
                    target: parent
                    from: 0
                    to: 360
                    duration: 2000 / Math.max(root.fanSpeed, 0.1)
                    loops: Animation.Infinite
                    running: root.fanOn
                }
            }

            // 速度百分比
            Text {
                text: root.fanOn ? Math.round(root.fanSpeed * 100) + "%" : "关闭"
                font.pixelSize: Style.fontXLarge
                font.family: Style.fontFamilyMono
                font.bold: true
                color: root.fanOn ? Style.textPrimary : Style.textSecondary
                Layout.fillWidth: true
            }
        }

        // 中间：速度滑块
        Slider {
            id: fanSlider
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            value: root.fanSpeed
            stepSize: 0.05

            onMoved: {
                // 滑块拖动时实时更新
                if (app && app.printer) {
                    app.printer.setFanSpeed(root.fanName, value)
                }
            }

            background: Rectangle {
                x: fanSlider.leftPadding
                y: fanSlider.topPadding + fanSlider.availableHeight / 2 - height / 2
                width: fanSlider.availableWidth
                height: Style.borderMedium
                radius: Style.radiusSmall
                color: Style.bgSecondary

                Rectangle {
                    width: fanSlider.visualPosition * parent.width
                    height: parent.height
                    color: Style.info
                    radius: Style.radiusSmall
                }
            }

            handle: Rectangle {
                x: fanSlider.leftPadding + fanSlider.visualPosition * (fanSlider.availableWidth - width)
                y: fanSlider.topPadding + fanSlider.availableHeight / 2 - height / 2
                width: Style.baseUnit * 2
                height: Style.baseUnit * 2
                radius: width / 2
                color: fanSlider.pressed ? Qt.lighter(Style.info, 1.2) : Style.info
                border.width: Style.borderThin
                border.color: Qt.lighter(Style.info, 1.3)
            }
        }

        // 底部：开关按钮
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.buttonHeight
            color: root.fanOn ? Style.success : Style.bgSecondary
            border.width: Style.borderThin
            border.color: Style.border
            radius: Style.radiusSmall

            Text {
                anchors.centerIn: parent
                text: root.fanOn ? "关闭风扇" : "开启风扇"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                color: root.fanOn ? Style.bgPrimary : Style.textPrimary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (app && app.printer) {
                        app.printer.setFanOnOff(root.fanName, !root.fanOn)
                    }
                }
            }
        }
    }
}
