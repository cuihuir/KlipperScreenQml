import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * FanWidget - 风扇控制 Widget
 *
 * 显示单个风扇的当前状态（开/关）和速度百分比。
 * 当前为占位符实现，显示静态"关闭"状态。
 *
 * 使用示例:
 *   FanWidget {
 *       widgetId: "fan_part_cooling"
 *       fanName: "打印冷却"
 *       fanSpeed: 0.0
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
     * 风扇速度（0.0-1.0，0 表示关闭）
     */
    property real fanSpeed: 0.0

    // ===== 基类属性配置 =====
    title: fanName
    widgetState: "idle"
    isInteractive: true

    // ===== 内容区域 =====
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingSmall

        // 风扇图标（旋转动画）
        Text {
            text: "⚙"  // 简易风扇图标（未来可替换为 SVG）
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            color: root.fanSpeed > 0 ? Style.info : Style.textDisabled
            Layout.alignment: Qt.AlignHCenter

            // 旋转动画（仅在风扇开启时）
            RotationAnimator {
                target: parent
                from: 0
                to: 360
                duration: 2000 / Math.max(root.fanSpeed, 0.1)  // 速度越快转速越快
                loops: Animation.Infinite
                running: root.fanSpeed > 0
            }
        }

        // 状态文本
        Text {
            text: root.fanSpeed > 0 ? (root.fanSpeed * 100).toFixed(0) + "%" : "关闭"
            font.pixelSize: Style.fontLarge
            font.family: Style.fontFamilyMono
            font.bold: true
            color: root.fanSpeed > 0 ? Style.textPrimary : Style.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ===== 点击事件（未来实现风扇速度调节） =====
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("FanWidget clicked:", root.fanName, "speed:", root.fanSpeed)
            // TODO: Phase 5 - 打开风扇速度调节对话框
        }
    }
}
