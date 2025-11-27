import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * GlobalNavButtons - 全局导航按钮组
 *
 * 左侧固定的 HOME 和 RETURN 按钮，遵循 iOS 风格导航模式。
 * - HOME 按钮：始终可用，点击返回主页
 * - RETURN 按钮：仅在导航深度 > 1 时可用，点击返回上一级
 *
 * 按钮尺寸: 80px 宽（符合触摸优化设计）
 *
 * 使用示例:
 *   GlobalNavButtons {
 *       width: 80
 *       height: parent.height
 *   }
 */
Rectangle {
    id: root

    // ===== 公共属性 =====

    /**
     * 按钮宽度（默认 80px）
     */
    property real buttonWidth: 80

    /**
     * 按钮高度（默认 80px，与宽度相同形成正方形）
     */
    property real buttonHeight: 80

    // ===== 视觉样式 =====
    color: Style.bgSecondary
    border.width: Style.borderThin
    border.color: Style.border

    // ===== 布局 =====
    implicitWidth: buttonWidth
    implicitHeight: parent ? parent.height : 400  // 默认高度

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingSmall
        spacing: Style.spacingMedium

        // ===== HOME 按钮 =====
        Rectangle {
            id: homeButton

            Layout.preferredWidth: root.buttonWidth - Style.spacingSmall * 2
            Layout.preferredHeight: root.buttonHeight
            Layout.alignment: Qt.AlignHCenter

            color: homeMouseArea.pressed ? Qt.darker(Style.accent, 1.2) :
                   homeMouseArea.containsMouse ? Qt.lighter(Style.accent, 1.1) :
                   Style.accent

            border.width: Style.borderMedium
            border.color: Qt.lighter(Style.accent, 1.2)
            radius: Style.radiusSmall

            // 状态转换动画
            Behavior on color {
                ColorAnimation {
                    duration: Style.durationFast
                    easing.type: Easing.OutCubic
                }
            }

            // 按钮内容
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.spacingXSmall

                // HOME 图标
                Text {
                    text: "🏠"
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamily
                    Layout.alignment: Qt.AlignHCenter
                }

                // HOME 文本
                Text {
                    text: "HOME"
                    font.pixelSize: Style.fontSmall
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.bgPrimary
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // 鼠标交互
            MouseArea {
                id: homeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    console.log("GlobalNavButtons: HOME button clicked")
                    navigationManager.popToRoot()
                }
            }

            // 点击缩放动画
            scale: homeMouseArea.pressed ? 0.95 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: Style.durationFast
                    easing.type: Easing.OutBack
                }
            }
        }

        // ===== RETURN 按钮 =====
        Rectangle {
            id: returnButton

            Layout.preferredWidth: root.buttonWidth - Style.spacingSmall * 2
            Layout.preferredHeight: root.buttonHeight
            Layout.alignment: Qt.AlignHCenter

            // 根据 navigationManager.canGoBack 动态启用/禁用
            enabled: navigationManager.canGoBack

            color: {
                if (!enabled) return Style.bgCard
                if (returnMouseArea.pressed) return Qt.darker(Style.info, 1.2)
                if (returnMouseArea.containsMouse) return Qt.lighter(Style.info, 1.1)
                return Style.info
            }

            border.width: Style.borderMedium
            border.color: enabled ? Qt.lighter(Style.info, 1.2) : Style.border
            radius: Style.radiusSmall
            opacity: enabled ? 1.0 : 0.5

            // 状态转换动画
            Behavior on color {
                ColorAnimation {
                    duration: Style.durationFast
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Style.durationFast
                    easing.type: Easing.OutCubic
                }
            }

            // 按钮内容
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.spacingXSmall

                // RETURN 图标
                Text {
                    text: "⬅️"
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamily
                    opacity: parent.parent.enabled ? 1.0 : 0.5
                    Layout.alignment: Qt.AlignHCenter
                }

                // RETURN 文本
                Text {
                    text: "RETURN"
                    font.pixelSize: Style.fontXSmall
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.bgPrimary
                    opacity: parent.parent.enabled ? 1.0 : 0.5
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // 鼠标交互
            MouseArea {
                id: returnMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: parent.enabled
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor

                onClicked: {
                    console.log("GlobalNavButtons: RETURN button clicked")
                    navigationManager.popPage()
                }
            }

            // 点击缩放动画
            scale: returnMouseArea.pressed ? 0.95 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: Style.durationFast
                    easing.type: Easing.OutBack
                }
            }
        }

        // ===== 填充空间 =====
        Item {
            Layout.fillHeight: true
        }

        // ===== 底部：导航深度指示器（调试用） =====
        Text {
            visible: false  // 生产环境隐藏
            text: "Depth: " + navigationManager.currentDepth
            font.pixelSize: Style.fontXSmall
            font.family: Style.fontFamilyMono
            color: Style.textDisabled
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ===== 调试日志 =====
    Component.onCompleted: {
        console.log("GlobalNavButtons created")
        console.log("navigationManager.canGoBack:", navigationManager.canGoBack)
        console.log("navigationManager.currentPage:", navigationManager.currentPage)
    }

    // 监听导航状态变化
    Connections {
        target: navigationManager

        function onNavigationChanged(pageId, depth) {
            console.log("GlobalNavButtons: Navigation changed ->", pageId, "depth:", depth)
        }

        function onCanGoBackChanged(canGoBack) {
            console.log("GlobalNavButtons: canGoBack changed ->", canGoBack)
        }
    }
}
