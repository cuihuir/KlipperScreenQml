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

    /**
     * StackView 引用（用于控制导航）
     */
    property StackView stackView: null

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

        // ===== HOME 按钮（圆形） =====
        Rectangle {
            id: homeButton

            Layout.preferredWidth: root.buttonWidth - Style.spacingSmall * 2
            Layout.preferredHeight: root.buttonWidth - Style.spacingSmall * 2
            Layout.alignment: Qt.AlignHCenter

            color: homeMouseArea.pressed ? Qt.darker(Style.accent, 1.2) :
                   homeMouseArea.containsMouse ? Qt.lighter(Style.accent, 1.1) :
                   Style.accent

            border.width: Style.borderMedium
            border.color: Qt.lighter(Style.accent, 1.2)
            radius: width / 2  // 圆形

            // 状态转换动画
            Behavior on color {
                ColorAnimation {
                    duration: Style.durationFast
                    easing.type: Easing.OutCubic
                }
            }

            // HOME 图标（居中） - 使用 KlipperScreen SVG
            ThemedIcon {
                anchors.centerIn: parent
                iconName: "home"
                iconSize: Style.fontXLarge
            }

            // 鼠标交互
            MouseArea {
                id: homeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    console.log("GlobalNavButtons: HOME button clicked, stackView:", root.stackView)
                    // 同时操作 StackView 和 NavigationManager
                    if (root.stackView && root.stackView.depth > 1) {
                        root.stackView.pop(null)  // Pop to root
                    }
                    if (navigationManager) {
                        navigationManager.popToRoot()
                    }
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

        // ===== RETURN/BACK 按钮（"<" 图标） =====
        Rectangle {
            id: returnButton

            Layout.preferredWidth: root.buttonWidth - Style.spacingSmall * 2
            Layout.preferredHeight: root.buttonWidth - Style.spacingSmall * 2
            Layout.alignment: Qt.AlignHCenter

            // 根据导航深度动态启用/禁用
            enabled: root.stackView ? root.stackView.depth > 1 : false

            color: {
                if (!enabled) return Style.bgCard
                if (returnMouseArea.pressed) return Qt.darker(Style.info, 1.2)
                if (returnMouseArea.containsMouse) return Qt.lighter(Style.info, 1.1)
                return Style.info
            }

            border.width: Style.borderMedium
            border.color: enabled ? Qt.lighter(Style.info, 1.2) : Style.border
            radius: Style.radiusSmall
            opacity: enabled ? 1.0 : 0.4

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

            // 返回图标 - 使用 KlipperScreen SVG
            ThemedIcon {
                anchors.centerIn: parent
                iconName: "arrow-left"
                iconSize: Style.fontXXLarge
                opacity: parent.enabled ? 1.0 : 0.4
            }

            // 鼠标交互
            MouseArea {
                id: returnMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: parent.enabled
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor

                onClicked: {
                    // 先检查是否有打开的 Overlay（Dialog/Popup）
                    var overlays = root.Window.window.Overlay.overlay
                    if (overlays && overlays.children.length > 0) {
                        // 查找打开的 Popup/Dialog
                        for (var i = overlays.children.length - 1; i >= 0; i--) {
                            var child = overlays.children[i]
                            if (child.visible && typeof child.close === "function") {
                                child.close()
                                return  // 关闭对话框后不执行导航
                            }
                        }
                    }

                    // 如果没有对话框，执行正常导航
                    if (root.stackView && root.stackView.depth > 1) {
                        root.stackView.pop()
                    }
                    if (navigationManager) {
                        navigationManager.popPage()
                    }
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
            text: navigationManager ? ("Depth: " + navigationManager.currentDepth) : "Depth: -"
            font.pixelSize: Style.fontXSmall
            font.family: Style.fontFamilyMono
            color: Style.textDisabled
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ===== 调试日志 =====
    Component.onCompleted: {
        console.log("GlobalNavButtons created")
        if (navigationManager) {
            console.log("navigationManager.canGoBack:", navigationManager.canGoBack)
            console.log("navigationManager.currentPage:", navigationManager.currentPage)
        } else {
            console.warn("navigationManager is not available yet")
        }
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
