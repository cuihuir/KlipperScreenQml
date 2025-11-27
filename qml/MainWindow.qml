import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "."
import "pages" as Pages
import "components" as Components

ApplicationWindow {
    id: root

    visible: true
    width: 1920
    height: 440

    title: "QtKs - Metro UI 3D Printer Controller"

    // 防止窗口调整大小
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height

    // 暗色主题背景
    color: Style.bgPrimary

    // 全局属性
    property var printer: app ? app.printer : null
    property var uiState: app ? app.uiState : null
    readonly property bool isConnected: printer ? printer.connected : false

    // 更新样式系统的窗口尺寸
    Component.onCompleted: {
        Style.updateWindowSize(width, height)
        console.log("✓ MainWindow loaded - Metro UI (1920x440) with iOS-style navigation")
    }

    // ===== 主布局：左侧全局按钮 + 右侧 StackView =====
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 左侧：全局导航按钮（80px 宽）
        Components.GlobalNavButtons {
            id: globalNav
            Layout.fillHeight: true
            Layout.preferredWidth: 80
            stackView: stackView  // 传递 StackView 引用
        }

        // 右侧：页面内容区域（StackView）
        StackView {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 初始页面：HomePage
            initialItem: homePageComponent

            // ===== 转场动画配置（iOS 风格） =====

            // Push 动画：新页面从右侧滑入
            pushEnter: Transition {
                PropertyAnimation {
                    property: "x"
                    from: stackView.width
                    to: 0
                    duration: Style.durationNormal
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0.8
                    to: 1.0
                    duration: Style.durationNormal
                }
            }

            // Push 动画：旧页面轻微向左移动
            pushExit: Transition {
                PropertyAnimation {
                    property: "x"
                    from: 0
                    to: -stackView.width * 0.3
                    duration: Style.durationNormal
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.5
                    duration: Style.durationNormal
                }
            }

            // Pop 动画：旧页面向右滑出
            popExit: Transition {
                PropertyAnimation {
                    property: "x"
                    from: 0
                    to: stackView.width
                    duration: Style.durationNormal
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: Style.durationNormal
                }
            }

            // Pop 动画：下层页面从左侧恢复
            popEnter: Transition {
                PropertyAnimation {
                    property: "x"
                    from: -stackView.width * 0.3
                    to: 0
                    duration: Style.durationNormal
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0.5
                    to: 1.0
                    duration: Style.durationNormal
                }
            }
        }
    }

    // ===== 页面组件定义 =====

    Component {
        id: homePageComponent
        Pages.HomePage {
            // StackView 会自动注入 stackView 属性
        }
    }

    Component {
        id: controlPageComponent
        Pages.ControlPage {
            printer: root.printer
        }
    }

    Component {
        id: filesPageComponent
        Pages.FilesPage {
            printer: root.printer
        }
    }

    Component {
        id: settingsPageComponent
        Pages.SettingsPage {
            printer: root.printer
        }
    }

    Component {
        id: printingPageComponent
        Pages.PrintingPage {
            printer: root.printer

            onBackToHomeRequested: {
                navigationManager.popToRoot()
            }
        }
    }

    Component {
        id: screensaverPageComponent
        Pages.ScreenSaverPage {
            printer: root.printer

            onWakeupRequested: {
                if (uiState) {
                    uiState.deactivateScreensaver()
                }
            }
        }
    }

    // ===== 页面注册表（T016 - 实现页面路由） =====

    QtObject {
        id: pageRegistry

        // 页面组件映射表
        readonly property var pages: ({
            "home": homePageComponent,
            "control": controlPageComponent,
            "files": filesPageComponent,
            "settings": settingsPageComponent,
            "printing": printingPageComponent,
            "screensaver": screensaverPageComponent
        })

        /**
         * 导航到指定页面
         * @param pageId 页面标识符
         * @param properties 传递给页面的属性对象（可选）
         */
        function navigateTo(pageId, properties) {
            console.log("pageRegistry.navigateTo:", pageId)

            // 验证页面是否存在
            if (!pages[pageId]) {
                console.error("Page not found:", pageId)
                return false
            }

            // 如果已经在目标页面，不重复导航
            if (navigationManager.currentPage === pageId) {
                console.log("Already on page:", pageId)
                return false
            }

            // Push 到 StackView
            if (properties) {
                stackView.push(pages[pageId], properties)
            } else {
                stackView.push(pages[pageId])
            }

            // 同步更新 NavigationManager
            navigationManager.pushPage(pageId)

            return true
        }

        /**
         * 返回上一级
         */
        function goBack() {
            if (stackView.depth > 1) {
                stackView.pop()
                navigationManager.popPage()
                return true
            }
            return false
        }

        /**
         * 返回主页
         */
        function goHome() {
            if (stackView.depth > 1) {
                stackView.pop(null)  // Pop all
                navigationManager.popToRoot()
                return true
            }
            return false
        }
    }

    // ===== 监听 NavigationManager 信号（保持同步） =====

    Connections {
        target: navigationManager

        function onPageEntered(pageId) {
            console.log("MainWindow: Page entered ->", pageId)
        }

        function onPageExited(pageId) {
            console.log("MainWindow: Page exited ->", pageId)
        }
    }

    // ===== 监听 UIState 屏保状态 =====

    Connections {
        target: uiState

        function onScreensaverActiveChanged() {
            if (uiState.screensaverActive) {
                // 屏保激活：全屏显示屏保页面（不通过导航栈）
                stackView.push(screensaverPageComponent)
            } else {
                // 屏保退出：返回之前的页面
                if (stackView.currentItem && stackView.currentItem.toString().indexOf("ScreenSaverPage") >= 0) {
                    stackView.pop()
                }
            }
        }
    }

    // ===== 占位符 Toast（全局） =====

    Components.PlaceholderToast {
        id: placeholderToast
    }

    // ===== 通知 Toast（用于打印机通知） =====

    Rectangle {
        id: notificationToast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Style.spacingLarge
        visible: false

        width: 400
        height: 80
        radius: Style.radiusSmall
        color: Style.info

        Label {
            anchors.centerIn: parent
            text: "打印机状态更新"
            font.pixelSize: Style.fontMedium
            color: "#FFFFFF"
        }

        // 自动隐藏定时器
        Timer {
            interval: 3000
            onTriggered: notificationToast.visible = false
        }
    }

    // ===== 工具函数 =====

    /**
     * 显示占位符 Toast
     */
    function showPlaceholder(featureName: string) {
        console.log("占位符功能点击:", featureName)
        placeholderToast.show(featureName)
    }

    /**
     * 显示通知
     */
    function showNotification(message: string) {
        console.log("通知:", message)
        // TODO: 实现通知显示逻辑
    }

    // ===== 键盘快捷键 =====

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "F1"
        onActivated: pageRegistry.goHome()
    }

    Shortcut {
        sequence: "F2"
        onActivated: pageRegistry.navigateTo("control")
    }

    Shortcut {
        sequence: "F3"
        onActivated: pageRegistry.navigateTo("files")
    }

    Shortcut {
        sequence: "F4"
        onActivated: pageRegistry.navigateTo("settings")
    }

    Shortcut {
        sequence: "Escape"
        onActivated: pageRegistry.goBack()
    }
}
