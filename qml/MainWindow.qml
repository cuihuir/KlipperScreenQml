import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components" as Components
import "pages" as Pages

ApplicationWindow {
    id: root
    visible: true
    width: app ? app.uiWidth : 800
    height: app ? app.uiHeight : 480
    title: app ? (app.appName + " v" + app.version) : "QtKs"
    flags: Qt.Window | Qt.FramelessWindowHint

    // Metro风格:纯黑背景
    color: Style.bgPrimary

    // 全局属性
    property var printer: app ? app.printer : null
    readonly property bool isConnected: printer ? printer.isConnected : false
    property int currentPage: 0  // 0: Dashboard, 1: Move, 2: Files, 3: AFC, 4: Settings
    readonly property bool isPrinting: printer && (printer.printerState === "printing" || printer.printerState === "paused")
    readonly property bool canMove: !printer || printer.printerState !== "printing"  // 只有printing时禁用MOVE

    // 更新样式系统的窗口尺寸
    onWidthChanged: Style.updateWindowSize(width, height)
    onHeightChanged: Style.updateWindowSize(width, height)

    // 监听打印机连接和状态
    Connections {
        target: printer
        enabled: printer !== null

        function onPrinterStateChanged(state) {
            console.log("=== Printer state changed signal received:", state)
        }
    }

    // 监听打印状态变化
    onIsPrintingChanged: {
        console.log("=== isPrinting changed to:", isPrinting, "printerState:", printer ? printer.printerState : "null")
    }

    // 监听MOVE可用性变化
    onCanMoveChanged: {
        // 如果MOVE页面被禁用且当前在MOVE页面，自动跳转到首页
        if (!canMove && currentPage === 1) {
            console.log("MOVE disabled (printing started), switching to Dashboard")
            currentPage = 0
        }
    }

    // 主内容区
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 导航栏 - Metro风格：扁平方块
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 4
            color: Style.bgSecondary

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Style.borderThin
                color: Style.divider
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: ListModel {
                        id: navModel
                        ListElement { icon: "HOME"; text: "主页"; page: 0; requiresCanMove: false }
                        ListElement { icon: "MOVE"; text: "移动"; page: 1; requiresCanMove: true }
                        ListElement { icon: "FILES"; text: "文件"; page: 2; requiresCanMove: false }
                        ListElement { icon: "AFC"; text: "多色"; page: 3; requiresCanMove: false }
                        ListElement { icon: "CONFIG"; text: "设置"; page: 4; requiresCanMove: false }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        // MOVE页面根据canMove状态决定是否可用
                        property bool isEnabled: !model.requiresCanMove || root.canMove
                        opacity: isEnabled ? 1.0 : 0.3  // 禁用时半透明
                        color: currentPage === model.page ? Style.accent : "transparent"

                        // 激活指示器
                        Rectangle {
                            anchors.top: parent.top
                            width: parent.width
                            height: Style.borderThick
                            color: Style.accent
                            visible: currentPage === model.page
                        }

                        // Hover效果背景
                        Rectangle {
                            anchors.fill: parent
                            color: Style.textPrimary
                            opacity: mouseArea.containsMouse && currentPage !== model.page ? 0.05 : 0
                            z: -1

                            Behavior on opacity {
                                NumberAnimation { duration: Style.durationFast }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Style.spacingXSmall

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: model.icon
                                font.pixelSize: Style.fontMedium
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 2
                                color: currentPage === model.page ? Style.bgPrimary : Style.textPrimary
                            }

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: model.text
                                font.pixelSize: Style.fontXSmall
                                font.family: Style.fontFamily
                                color: currentPage === model.page ? Style.bgPrimary : Style.textSecondary
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: parent.isEnabled  // 禁用时不响应点击
                            cursorShape: parent.isEnabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                            onClicked: {
                                if (parent.isEnabled) {
                                    currentPage = model.page
                                }
                            }
                        }
                    }
                }
            }
        }

        // 页面内容 - 性能优化：使用 Loader 按需加载，只渲染当前页面
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true

            sourceComponent: {
                switch(currentPage) {
                    case 0: return dashboardPageComponent
                    case 1: return movePageComponent
                    case 2: return filesPageComponent
                    case 3: return afcPageComponent
                    case 4: return settingsPageComponent
                    default: return dashboardPageComponent
                }
            }

            // 页面组件定义
            Component {
                id: dashboardPageComponent
                Pages.DashboardPage {
                    printer: root.printer
                    app: app
                    onShowError: function(msg) { root.showError(msg) }
                    onNavigateToFiles: currentPage = 2
                }
            }

            Component {
                id: movePageComponent
                Pages.MovePage {
                    printer: root.printer
                    app: app
                    onShowError: function(msg) { root.showError(msg) }
                }
            }

            Component {
                id: filesPageComponent
                Pages.FilesPage {
                    printer: root.printer
                    app: app
                    onShowError: function(msg) { root.showError(msg) }
                    onNavigateToDashboard: currentPage = 0
                }
            }

            Component {
                id: afcPageComponent
                Pages.AfcPage {
                    printer: root.printer
                    app: app
                    onShowError: function(msg) { root.showError(msg) }
                }
            }

            Component {
                id: settingsPageComponent
                Pages.SettingsPage {
                    printer: root.printer
                    app: app
                    onShowError: function(msg) { root.showError(msg) }
                }
            }
        }
    }

    // 底部状态栏
    footer: Components.StatusBar {
        printer: root.printer
    }

    // 通知系统 (右上角Toast)
    Components.NotificationToast {
        id: notificationToast
    }

    // 监听通知信号
    Connections {
        target: printer
        enabled: printer !== null

        function onNotificationReceived(type, message) {
            console.log("Notification:", type, message)
            notificationToast.show(type, message)
        }
    }

    // 全局错误提示 Toast (保留用于非Klipper错误)
    Rectangle {
        id: errorToast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.baseUnit * 8
        width: Math.min(parent.width * 0.8, Style.baseUnit * 30)
        height: Style.baseUnit * 3
        color: Style.error
        border.width: Style.borderMedium
        border.color: Style.divider
        radius: Style.radiusSmall
        visible: opacity > 0
        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: Style.durationNormal }
        }

        property string message: ""

        Label {
            anchors.centerIn: parent
            anchors.margins: Style.spacingMedium
            text: errorToast.message
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width - Style.spacingMedium * 2
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: errorToast.opacity = 0
        }

        function show(msg) {
            message = msg
            opacity = 1
            toastTimer.restart()
        }
    }

    // 辅助函数
    function showError(message) {
        errorToast.show(message)
    }

    function getPrinterStateColor() {
        if (!printer) return Style.textDisabled

        switch(printer.printerState) {
            case "ready": return Style.success
            case "printing": return Style.info
            case "paused": return Style.warning
            case "error": return Style.error
            case "shutdown": return Style.error
            default: return Style.textDisabled
        }
    }

    function getPrinterStateText() {
        if (!printer) return "OFFLINE"

        switch(printer.printerState) {
            case "ready": return "READY"
            case "printing": return "PRINTING"
            case "paused": return "PAUSED"
            case "error": return "ERROR"
            case "shutdown": return "SHUTDOWN"
            case "standby": return "STANDBY"
            default: return printer.printerState.toUpperCase()
        }
    }

    Component.onCompleted: {
        console.log("✓ MainWindow loaded (Metro style)")
        Style.updateWindowSize(width, height)
        console.log("=== Initial printer state:", printer ? printer.printerState : "null")
        console.log("=== Initial isPrinting:", isPrinting)
    }
}
