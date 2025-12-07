import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * HomeWidget 基类
 *
 * 主页 Widget 的抽象基类，提供统一的状态管理和视觉样式。
 * 所有主页 Widget（温度、风扇、LED、打印控制）都应继承此组件。
 *
 * 状态机:
 * - idle: 正常空闲状态（默认）
 * - active: 激活/交互状态（用户点击或正在编辑）
 * - updating: 正在更新数据状态（显示加载指示器）
 * - error: 错误状态（显示错误指示器）
 *
 * 使用示例:
 *   HomeWidget {
 *       widgetId: "temp_hotend"
 *       title: "热端温度"
 *       widgetState: "idle"
 *       isInteractive: true
 *   }
 */
Rectangle {
    id: root

    // ===== 公共属性 =====

    /**
     * Widget 唯一标识符（用于状态管理和调试）
     */
    property string widgetId: ""

    /**
     * Widget 标题（显示在顶部）
     */
    property string title: ""

    /**
     * Widget 当前状态
     * @values "idle" | "active" | "updating" | "error"
     */
    property string widgetState: "idle"

    /**
     * 是否可交互（禁用时整体变暗）
     */
    property bool isInteractive: true

    /**
     * 错误消息（当 widgetState == "error" 时显示）
     */
    property string errorMessage: ""

    // ===== 内部状态 =====

    /**
     * 是否悬停（用于交互反馈）
     */
    property bool hovered: mouseArea.containsMouse

    // ===== 默认内容区域（子类通过 default property 填充内容） =====
    default property alias contentData: contentContainer.data

    // ===== 视觉样式 =====

    color: {
        if (!isInteractive) return Style.bgSecondary
        if (widgetState === "active") return Style.bgCard
        if (widgetState === "error") return Qt.rgba(Style.error.r, Style.error.g, Style.error.b, 0.1)
        if (hovered && isInteractive) return Style.bgCard
        return Style.bgSecondary
    }

    border.width: {
        if (widgetState === "active") return Style.borderMedium
        if (widgetState === "error") return Style.borderMedium
        return Style.borderThin
    }

    border.color: {
        if (widgetState === "active") return Style.accent
        if (widgetState === "error") return Style.error
        if (hovered && isInteractive) return Qt.lighter(Style.border, 1.2)
        return Style.border
    }

    radius: Style.radiusSmall  // 从 radiusTiny 改为 radiusSmall，更明显的圆角

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

    Behavior on border.width {
        NumberAnimation {
            duration: Style.durationFast
            easing.type: Easing.OutCubic
        }
    }

    // ===== 鼠标交互区域 =====
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.isInteractive
        cursorShape: root.isInteractive ? Qt.PointingHandCursor : Qt.ArrowCursor

        // 点击事件由子类实现
        onClicked: {
            console.log("HomeWidget clicked:", root.widgetId)
        }
    }

    // ===== 布局容器 =====
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingNormal  // 统一使用 spacingNormal 确保一致性
        spacing: Style.spacingSmall

        // 标题栏
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            // 标题文本
            Text {
                text: root.title
                font.pixelSize: Style.fontMedium
                font.bold: true
                font.family: Style.fontFamily
                color: root.isInteractive ? Style.textPrimary : Style.textDisabled
                Layout.fillWidth: true
            }

            // 状态指示器（右侧）
            Loader {
                active: root.widgetState === "updating" || root.widgetState === "error"
                sourceComponent: statusIndicatorComponent
            }
        }

        // 内容区域（子类填充）
        Item {
            id: contentContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // 错误提示（仅在 error 状态显示）
        Text {
            visible: root.widgetState === "error" && root.errorMessage !== ""
            text: root.errorMessage
            font.pixelSize: Style.fontSmall
            font.family: Style.fontFamily
            color: Style.error
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    // ===== 状态指示器组件 =====
    Component {
        id: statusIndicatorComponent

        Item {
            width: Style.iconSizeSmall
            height: Style.iconSizeSmall

            // Metro 点阵式加载指示器（3 个圆点交替闪烁）
            Row {
                visible: root.widgetState === "updating"
                anchors.centerIn: parent
                spacing: 3

                Repeater {
                    model: 3
                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: Style.accent

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: root.widgetState === "updating"
                            // 每个圆点延迟 200ms 开始动画
                            PauseAnimation { duration: index * 200 }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 400; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.0; to: 0.3; duration: 400; easing.type: Easing.InOutQuad }
                            PauseAnimation { duration: (2 - index) * 200 }
                        }
                    }
                }
            }

            // 错误指示器（红色感叹号）
            Text {
                visible: root.widgetState === "error"
                anchors.centerIn: parent
                text: "⚠"
                font.pixelSize: Style.iconSizeSmall
                font.family: Style.fontFamily
                color: Style.error
            }
        }
    }

    // ===== 调试信息 =====
    Component.onCompleted: {
        console.log("HomeWidget created:", widgetId, "state:", widgetState)
    }

    // 状态变化日志
    onWidgetStateChanged: {
        console.log("HomeWidget state changed:", widgetId, "->", widgetState)
    }
}
