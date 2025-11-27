import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * FunctionIcon - 功能入口图标
 *
 * 主页右侧区域的功能图标，点击后导航到对应页面。
 * 采用 Metro 设计风格，支持悬停反馈和点击动画。
 *
 * 使用示例:
 *   FunctionIcon {
 *       iconId: "settings"
 *       label: "设置"
 *       iconPath: "qrc:/assets/icons/settings.png"
 *       targetPage: "settings"
 *       onIconClicked: navigationManager.pushPage(targetPage)
 *   }
 */
Rectangle {
    id: root

    // ===== 公共属性 =====

    /**
     * 图标唯一标识符
     */
    property string iconId: ""

    /**
     * 图标标签（显示在图标下方）
     */
    property string label: ""

    /**
     * 图标路径（PNG/SVG）
     * 当前使用 emoji 占位符，未来可替换为实际图标文件
     */
    property string iconPath: ""

    /**
     * 目标页面 ID（用于导航）
     */
    property string targetPage: ""

    /**
     * 图标 emoji（占位符，优先于 iconPath）
     */
    property string iconEmoji: "📄"

    /**
     * 是否禁用
     */
    property bool enabled: true

    // ===== 信号 =====

    /**
     * 点击信号（携带 iconId 和 targetPage）
     */
    signal iconClicked(string iconId, string targetPage)

    // ===== 内部状态 =====
    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed

    // ===== 视觉样式 =====
    color: {
        if (!root.enabled) return Style.bgSecondary
        if (root.pressed) return Qt.darker(Style.bgCard, 1.1)
        if (root.hovered) return Style.bgCard
        return Style.bgSecondary
    }

    border.width: root.hovered || root.pressed ? Style.borderMedium : Style.borderThin
    border.color: {
        if (!root.enabled) return Style.border
        if (root.pressed) return Style.accent
        if (root.hovered) return Qt.lighter(Style.border, 1.2)
        return Style.border
    }

    radius: Style.radiusSmall

    // ===== 状态转换动画 =====
    Behavior on color {
        ColorAnimation {
            duration: Style.durationFast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Style.durationFast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Style.durationFast
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    // ===== 点击缩放动画 =====
    scale: root.pressed ? 0.95 : 1.0

    // ===== 鼠标交互 =====
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            console.log("FunctionIcon clicked:", root.iconId, "->", root.targetPage)
            root.iconClicked(root.iconId, root.targetPage)
        }
    }

    // ===== 布局 =====
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingSmall

        // 图标区域
        Item {
            Layout.preferredWidth: Style.baseUnit * 4
            Layout.preferredHeight: Style.baseUnit * 4
            Layout.alignment: Qt.AlignHCenter

            // 占位符 Emoji（当前使用）
            Text {
                visible: root.iconEmoji !== "" && root.iconPath === ""
                anchors.centerIn: parent
                text: root.iconEmoji
                font.pixelSize: Style.fontXXLarge
                font.family: Style.fontFamily
                color: root.enabled ? Style.textPrimary : Style.textDisabled
                opacity: root.enabled ? 1.0 : 0.5

                Behavior on color {
                    ColorAnimation { duration: Style.durationFast }
                }
            }

            // 图标图片（未来实现）
            Image {
                visible: root.iconPath !== ""
                anchors.centerIn: parent
                width: Style.baseUnit * 3
                height: Style.baseUnit * 3
                source: root.iconPath
                fillMode: Image.PreserveAspectFit
                opacity: root.enabled ? 1.0 : 0.5

                Behavior on opacity {
                    NumberAnimation { duration: Style.durationFast }
                }
            }
        }

        // 标签文本
        Text {
            text: root.label
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            font.bold: root.hovered
            color: root.enabled ? Style.textPrimary : Style.textDisabled
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: root.width - Style.spacingMedium * 2
            elide: Text.ElideRight

            Behavior on color {
                ColorAnimation { duration: Style.durationFast }
            }

            Behavior on font.bold {
                // QML 不支持 font.bold 的 Behavior，手动通过 color 模拟
            }
        }
    }

    // ===== 悬停发光效果（可选） =====
    Rectangle {
        visible: root.hovered && root.enabled
        anchors.fill: parent
        anchors.margins: -Style.borderThin
        color: "transparent"
        border.width: Style.borderThin
        border.color: Qt.rgba(Style.accent.r, Style.accent.g, Style.accent.b, 0.3)
        radius: root.radius + Style.borderThin
        opacity: 0.6

        // 呼吸动画
        SequentialAnimation on opacity {
            running: root.hovered && root.enabled
            loops: Animation.Infinite

            NumberAnimation {
                from: 0.4
                to: 0.8
                duration: 800
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                from: 0.8
                to: 0.4
                duration: 800
                easing.type: Easing.InOutSine
            }
        }
    }

    // ===== 调试日志 =====
    Component.onCompleted: {
        console.log("FunctionIcon created:", iconId, "->", targetPage)
    }
}
