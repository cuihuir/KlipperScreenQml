import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * PrintControlWidget - 打印控制 Widget
 *
 * 显示打印状态和提供打印控制按钮。
 * 当前为占位符实现，仅显示"开始打印"按钮（idle 状态）。
 *
 * 状态机:
 * - idle: 空闲状态，显示"开始打印"按钮
 * - printing: 打印中，显示暂停/取消按钮和进度
 * - paused: 暂停状态，显示恢复/取消按钮
 * - complete: 打印完成，显示"完成"提示
 *
 * 使用示例:
 *   PrintControlWidget {
 *       widgetId: "print_control"
 *       printState: "idle"
 *       progress: 0.0
 *   }
 */
HomeWidget {
    id: root

    // ===== 公共属性 =====

    /**
     * 打印状态 - 内部属性，由数据绑定更新
     * @values "standby" | "printing" | "paused" | "complete" | "error"
     */
    property string printState: "standby"

    /**
     * 打印进度（0.0-100.0）- 内部属性，由数据绑定更新
     */
    property real progress: 0.0

    /**
     * 当前打印文件名 - 内部属性，由数据绑定更新
     */
    property string currentFileName: ""

    // ===== 基类属性配置 =====
    title: ""  // 空闲状态不显示标题
    widgetState: "idle"
    isInteractive: true

    // ===== 数据绑定：连接 MoonrakerClient =====
    Connections {
        target: app ? app.printer : null

        function onPrinterStateChanged(state) {
            // Moonraker 状态映射到 Widget 状态
            // Klipper states: ready, standby, printing, paused, complete, error, shutdown, offline
            console.log("PrintControlWidget: state changed to", state)
            root.printState = state
        }

        function onPrintProgressChanged(data) {
            root.progress = data.progress || 0.0
            root.currentFileName = data.filename || ""
        }
    }

    // 组件加载完成后初始化状态
    Component.onCompleted: {
        if (app && app.printer) {
            root.printState = app.printer.printerState || ""
            console.log("PrintControlWidget initialized, initial state:", root.printState)
        } else {
            console.log("PrintControlWidget: app or printer is null, state:", root.printState)
        }
    }

    // 监听printState变化
    onPrintStateChanged: {
        console.log("PrintControlWidget: printState changed to:", printState)
    }

    // Complete 状态自动切换定时器
    Timer {
        id: completeTimer
        interval: 3000
        running: root.printState === "complete"
        onTriggered: {
            root.printState = "standby"
        }
    }

    // ===== 内容区域 =====
    ColumnLayout {
        anchors.fill: parent
        spacing: Style.spacingMedium

        // 状态显示区域（可点击进入详情页）
        Rectangle {
            visible: root.printState !== "standby" && root.printState !== "ready"
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 3
            color: "transparent"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.spacingSmall

                // 文件名
                Text {
                    visible: root.currentFileName !== ""
                    text: root.currentFileName
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    color: Style.textPrimary
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: root.width - Style.spacingLarge * 2
                    Layout.alignment: Qt.AlignHCenter
                }

                // 进度条
                ProgressBar {
                    visible: root.printState === "printing" || root.printState === "paused"
                    from: 0
                    to: 1
                    value: root.progress
                    Layout.preferredWidth: root.width - Style.spacingLarge * 2
                    Layout.preferredHeight: Style.baseUnit * 0.5

                    background: Rectangle {
                        color: Style.bgCard
                        border.width: Style.borderThin
                        border.color: Style.border
                        radius: Style.radiusTiny
                    }

                    contentItem: Rectangle {
                        width: parent.visualPosition * parent.width
                        color: Style.getProgressColor(root.progress * 100)
                        radius: Style.radiusTiny
                    }
                }

                // 进度百分比
                Text {
                    visible: root.printState === "printing" || root.printState === "paused"
                    text: (root.progress * 100).toFixed(1) + "%"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }

                // 提示文字
                Text {
                    visible: root.printState === "printing" || root.printState === "paused"
                    text: "点击查看详情"
                    font.pixelSize: Style.fontSmall
                    color: Style.textSecondary
                    opacity: 0.6
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Clickable area to navigate to JobStatusPage
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    console.log("PrintControlWidget clicked, state:", root.printState)
                    if (root.printState === "printing" || root.printState === "paused") {
                        console.log("Navigating to JobStatusPage...")
                        var appWindow = root.Window.window
                        if (appWindow && appWindow.pageRegistry) {
                            appWindow.pageRegistry.navigateTo("job_status")
                        }
                    }
                }
                onEntered: {
                    parent.opacity = 0.8
                }
                onExited: {
                    parent.opacity = 1.0
                }
            }
        }

        // 按钮区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Idle/Standby/Ready 状态：左右2列布局，左侧图标，右侧文字
            Row {
                visible: root.printState === "" ||
                         root.printState === "offline" ||
                         root.printState === "ready" ||
                         root.printState === "standby" ||
                         root.printState === "cancelled"
                anchors.fill: parent
                spacing: 0

                // 左侧列：50%，小船图标居中（向上偏移）
                Item {
                    width: parent.width / 2
                    height: parent.height

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -parent.height * 0.2
                        width: Math.min(parent.width * 1.5, parent.height * 1.5)
                        height: width
                        source: "../../assets/icons/benchy.png"
                        fillMode: Image.PreserveAspectFit
                        opacity: fileMouseArea.containsMouse ? 1.0 : 0.85

                        Behavior on opacity {
                            NumberAnimation { duration: Style.durationFast }
                        }

                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.log("PrintControlWidget: Image load error:", source)
                            } else if (status === Image.Ready) {
                                console.log("PrintControlWidget: Image loaded successfully:", source)
                            }
                        }
                    }
                }

                // 右侧列：50%，"打印"文字居中（向上偏移）
                Item {
                    width: parent.width / 2
                    height: parent.height

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -parent.height * 0.2
                        text: "打印"
                        font.pixelSize: Math.min(parent.width * 0.6, parent.height * 0.6)
                        font.family: Style.fontFamily
                        font.bold: true
                        font.letterSpacing: 20
                        color: fileMouseArea.containsMouse ? Style.accent : Qt.rgba(Style.accent.r, Style.accent.g, Style.accent.b, 0.7)

                        Behavior on color {
                            ColorAnimation { duration: Style.durationFast }
                        }
                    }
                }
            }

            // MouseArea 在外层，避免遮挡内容
            MouseArea {
                id: fileMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                visible: root.printState === "" ||
                         root.printState === "offline" ||
                         root.printState === "ready" ||
                         root.printState === "standby" ||
                         root.printState === "cancelled"

                onClicked: {
                    // 导航到文件页面选择文件
                    var appWindow = root.Window.window
                    if (appWindow && appWindow.pageRegistry) {
                        appWindow.pageRegistry.navigateTo("files")
                    }
                }
            }

            // Printing 状态：暂停/取消按钮
            RowLayout {
                visible: root.printState === "printing"
                anchors.fill: parent
                spacing: Style.spacingMedium

                Button {
                    text: "暂停"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.warning, 1.2) :
                               parent.hovered ? Qt.lighter(Style.warning, 1.1) :
                               Style.warning
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (app && app.printer) {
                            app.printer.pausePrint()
                        }
                    }
                }

                Button {
                    text: "取消"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.error, 1.2) :
                               parent.hovered ? Qt.lighter(Style.error, 1.1) :
                               Style.error
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        cancelConfirmDialog.open()
                    }
                }
            }

            // Paused 状态：恢复/取消按钮
            RowLayout {
                visible: root.printState === "paused"
                anchors.fill: parent
                spacing: Style.spacingMedium

                Button {
                    text: "恢复"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.success, 1.2) :
                               parent.hovered ? Qt.lighter(Style.success, 1.1) :
                               Style.success
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (app && app.printer) {
                            app.printer.resumePrint()
                        }
                    }
                }

                Button {
                    text: "取消"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.error, 1.2) :
                               parent.hovered ? Qt.lighter(Style.error, 1.1) :
                               Style.error
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        cancelConfirmDialog.open()
                    }
                }
            }

            // Complete 状态：完成提示
            ColumnLayout {
                visible: root.printState === "complete"
                anchors.centerIn: parent
                spacing: Style.spacingSmall

                Text {
                    text: "✓ 打印完成"
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.success
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: root.currentFileName
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    color: Style.textSecondary
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: root.width - Style.spacingLarge * 2
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Error 状态：错误提示
            ColumnLayout {
                visible: root.printState === "error" || root.printState === "shutdown"
                anchors.centerIn: parent
                spacing: Style.spacingMedium

                Text {
                    text: "⚠ 打印错误"
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.error
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "查看详情"
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.warning, 1.2) : Style.warning
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        // 导航到打印详情页查看错误
                        var appWindow = root.Window.window
                        if (appWindow && appWindow.pageRegistry) {
                            appWindow.pageRegistry.navigateTo("printing")
                        }
                    }
                }
            }
        }
    }

    // ===== 取消打印确认对话框 =====
    Dialog {
        id: cancelConfirmDialog
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay

        width: Style.baseUnit * 30
        height: Style.baseUnit * 15

        title: "确认取消打印"

        background: Rectangle {
            color: Style.bgCard
            border.width: Style.borderMedium
            border.color: Style.divider
            radius: Style.radiusSmall
        }

        contentItem: ColumnLayout {
            spacing: Style.spacingLarge

            Text {
                text: "确定要取消当前打印吗？"
                font.pixelSize: Style.fontLarge
                font.family: Style.fontFamily
                color: Style.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: root.currentFileName
                font.pixelSize: Style.fontNormal
                font.family: Style.fontFamilyMono
                color: Style.textSecondary
                elide: Text.ElideMiddle
                Layout.maximumWidth: parent.width - Style.spacingLarge * 2
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacingMedium

                Button {
                    text: "取消操作"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.bgSecondary, 1.2) : Style.bgSecondary
                        radius: Style.radiusSmall
                        border.width: Style.borderThin
                        border.color: Style.border
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        cancelConfirmDialog.close()
                    }
                }

                Button {
                    text: "确定取消"
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.error, 1.2) : Style.error
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (app && app.printer) {
                            app.printer.cancelPrint()
                        }
                        cancelConfirmDialog.close()
                    }
                }
            }
        }
    }
}
