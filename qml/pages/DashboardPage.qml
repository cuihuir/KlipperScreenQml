import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

import "../components" as Components

// Metro风格主页
Page {
    id: root

    property var printer: null
    property var app: null
    property bool showKeypad: false
    property string keypadTitle: "ENTER TEMPERATURE"
    property var keypadCallback: null

    signal showError(string message)
    signal navigateToFiles()

    readonly property bool isPrinting: printer && (printer.printerState === "printing" || printer.printerState === "paused")

    background: Rectangle {
        color: Style.bgPrimary
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // 左侧 - 温度控制
        Components.TemperaturePanel {
            id: tempPanel
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.35
            Layout.minimumWidth: Style.baseUnit * 15
            printer: root.printer
            onTemperatureEditRequested: function(title, callback) {
                root.keypadTitle = title
                root.keypadCallback = callback
                root.showKeypad = true
            }
        }

        // 右侧布局 - 带翻转动画
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 正面 - 欢迎页/打印控制
            ColumnLayout {
                id: frontSide
                anchors.fill: parent
                spacing: Style.spacingLarge
                visible: !showKeypad

                transform: Rotation {
                    id: frontRotation
                    origin.x: frontSide.width / 2
                    origin.y: frontSide.height / 2
                    axis { x: 0; y: 1; z: 0 }
                    angle: 0

                    Behavior on angle {
                        NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
                    }
                }

                // 上方 - 欢迎页/缩略图
                Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                // 判断是否有错误
                readonly property bool hasError: printer && (printer.printerState === "error" || printer.printerState === "shutdown") && printer.errorMessage

                Loader {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    sourceComponent: hasError ? errorComponent : (isPrinting ? printingComponent : welcomeComponent)
                }

                // 错误状态 - 显示Klipper错误
                Component {
                    id: errorComponent

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Style.spacingMedium

                        // 错误图标和标题
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Style.spacingSmall

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: "⚠"
                                font.pixelSize: Style.baseUnit * 4
                                color: Style.error
                            }

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: "KLIPPER ERROR"
                                font.pixelSize: Style.fontLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 3
                                color: Style.error
                            }
                        }

                        // 错误消息滚动区域
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            // 滚动按钮
                            ColumnLayout {
                                Layout.preferredWidth: Style.baseUnit * 2
                                Layout.fillHeight: true
                                spacing: Style.spacingSmall

                                Item { Layout.fillHeight: true }

                                Rectangle {
                                    Layout.preferredWidth: Style.baseUnit * 1.8
                                    Layout.preferredHeight: Style.baseUnit * 1.8
                                    Layout.alignment: Qt.AlignHCenter
                                    color: errorScrollView.ScrollBar.vertical.position > 0 ? Style.accent : Style.bgSecondary
                                    border.width: Style.borderThin
                                    border.color: Style.divider

                                    Label {
                                        anchors.centerIn: parent
                                        text: "▲"
                                        font.pixelSize: Style.fontSmall
                                        color: errorScrollView.ScrollBar.vertical.position > 0 ? Style.bgPrimary : Style.textDisabled
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: errorScrollView.ScrollBar.vertical.position > 0
                                        onClicked: {
                                            errorScrollView.ScrollBar.vertical.position = Math.max(0, errorScrollView.ScrollBar.vertical.position - 0.2)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: Style.baseUnit * 1.8
                                    Layout.preferredHeight: Style.baseUnit * 1.8
                                    Layout.alignment: Qt.AlignHCenter
                                    color: (errorScrollView.ScrollBar.vertical.position + errorScrollView.ScrollBar.vertical.size) < 1.0 ? Style.accent : Style.bgSecondary
                                    border.width: Style.borderThin
                                    border.color: Style.divider

                                    Label {
                                        anchors.centerIn: parent
                                        text: "▼"
                                        font.pixelSize: Style.fontSmall
                                        color: (errorScrollView.ScrollBar.vertical.position + errorScrollView.ScrollBar.vertical.size) < 1.0 ? Style.bgPrimary : Style.textDisabled
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: (errorScrollView.ScrollBar.vertical.position + errorScrollView.ScrollBar.vertical.size) < 1.0
                                        onClicked: {
                                            errorScrollView.ScrollBar.vertical.position = Math.min(1.0 - errorScrollView.ScrollBar.vertical.size, errorScrollView.ScrollBar.vertical.position + 0.2)
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true }
                            }

                            // 错误消息文本
                            ScrollView {
                                id: errorScrollView
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                                Label {
                                    text: printer ? printer.errorMessage : ""
                                    font.pixelSize: Style.fontSmall
                                    font.family: Style.fontFamilyMono
                                    color: Style.textPrimary
                                    wrapMode: Text.WordWrap
                                    width: errorScrollView.width - Style.spacingSmall
                                }
                            }
                        }

                        // 操作按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.spacingSmall

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.baseUnit * 2.5
                                color: Style.warning
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: "RESTART"
                                    font.pixelSize: Style.fontSmall
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    font.letterSpacing: 2
                                    color: Style.bgPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (printer) printer.restartKlipper()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.baseUnit * 2.5
                                color: Style.error
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: "FIRMWARE RESTART"
                                    font.pixelSize: Style.fontXSmall
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    font.letterSpacing: 1
                                    color: Style.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (printer) printer.firmwareRestart()
                                    }
                                }
                            }
                        }
                    }
                }

                // 待机状态 - 欢迎页
                Component {
                    id: welcomeComponent

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Style.spacingLarge

                        Item { Layout.fillHeight: true }

                        // 打印机图标
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🖨"
                            font.pixelSize: Style.baseUnit * 6
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "WELCOME TO QTKS"
                            font.pixelSize: Style.fontXLarge
                            font.family: Style.fontFamily
                            font.bold: true
                            font.letterSpacing: 4
                            color: Style.accent
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "3D Printer Interface"
                            font.pixelSize: Style.fontMedium
                            font.family: Style.fontFamily
                            font.letterSpacing: 2
                            color: Style.textSecondary
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                // 打印状态 - 缩略图
                Component {
                    id: printingComponent

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Style.spacingSmall

                        Label {
                            text: "PRINTING"
                            font.pixelSize: Style.fontMedium
                            font.family: Style.fontFamily
                            font.bold: true
                            font.letterSpacing: 2
                            color: Style.textPrimary
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: Style.borderThin
                            color: Style.divider
                        }

                        // 缩略图占位
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Style.bgSecondary
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "G-CODE\nTHUMBNAIL"
                                font.pixelSize: Style.fontLarge
                                font.family: Style.fontFamily
                                font.letterSpacing: 2
                                color: Style.textDisabled
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        // 文件名
                        Label {
                            Layout.fillWidth: true
                            text: printer ? (printer.printFilename || "NONE") : "NONE"
                            font.pixelSize: Style.fontNormal
                            font.family: Style.fontFamilyMono
                            color: Style.textPrimary
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }

            // 下方 - 打印控制
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingMedium

                    // 待机状态 - 开始打印按钮
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Style.spacingLarge
                        visible: !isPrinting

                        Item { Layout.fillHeight: true }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.baseUnit * 5
                            color: Style.info
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "START PRINT"
                                font.pixelSize: Style.fontXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 3
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigateToFiles()
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Select a G-code file to begin printing"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            color: Style.textSecondary
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // 打印状态 - 控制按钮
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: Style.spacingMedium
                        visible: isPrinting

                        // 进度条
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Style.spacingSmall

                            RowLayout {
                                Layout.fillWidth: true

                                Label {
                                    text: "PROGRESS"
                                    font.pixelSize: Style.fontMedium
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    font.letterSpacing: 2
                                    color: Style.textPrimary
                                }

                                Item { Layout.fillWidth: true }

                                Label {
                                    text: printer ? (printer.printProgress.toFixed(1) + "%") : "0.0%"
                                    font.pixelSize: Style.fontXLarge
                                    font.family: Style.fontFamilyMono
                                    font.bold: true
                                    color: Style.accent
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: Style.baseUnit
                                color: Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Rectangle {
                                    width: (printer ? printer.printProgress / 100 : 0) * parent.width
                                    height: parent.height
                                    color: Style.info

                                    Behavior on width {
                                        NumberAnimation { duration: Style.durationNormal }
                                    }
                                }
                            }
                        }

                        // 控制按钮
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.spacingSmall

                            // 暂停/继续
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.buttonHeightLarge
                                color: printer && printer.printerState === "paused" ? Style.success : Style.warning
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: printer && printer.printerState === "paused" ? "RESUME" : "PAUSE"
                                    font.pixelSize: Style.fontLarge
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    font.letterSpacing: 2
                                    color: Style.bgPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (printer) {
                                            if (printer.printerState === "paused") {
                                                printer.resumePrint()
                                            } else {
                                                printer.pausePrint()
                                            }
                                        }
                                    }
                                }
                            }

                            // 取消
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Style.buttonHeightLarge
                                color: Style.error
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: "CANCEL"
                                    font.pixelSize: Style.fontLarge
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    font.letterSpacing: 2
                                    color: Style.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: cancelDialog.open()
                                }
                            }
                        }

                        // Z Offset 微调
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Style.spacingSmall

                            Label {
                                text: "Z OFFSET"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 1
                                color: Style.textSecondary
                                Layout.preferredWidth: Style.baseUnit * 5
                            }

                            Rectangle {
                                Layout.preferredWidth: Style.baseUnit * 4
                                Layout.preferredHeight: Style.buttonHeight
                                color: Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: "-"
                                    font.pixelSize: Style.fontXLarge
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    color: Style.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: adjustZOffset(-0.01)
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                text: "0.00 mm"
                                font.pixelSize: Style.fontNormal
                                font.family: Style.fontFamilyMono
                                font.bold: true
                                color: Style.accent
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Rectangle {
                                Layout.preferredWidth: Style.baseUnit * 4
                                Layout.preferredHeight: Style.buttonHeight
                                color: Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider

                                Label {
                                    anchors.centerIn: parent
                                    text: "+"
                                    font.pixelSize: Style.fontXLarge
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    color: Style.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: adjustZOffset(0.01)
                                }
                            }
                        }
                    }
                }
            }
        }

        // 背面 - 数字键盘
        Components.NumericKeypad {
            id: backSide
            anchors.fill: parent
            visible: showKeypad
            title: keypadTitle
            maxLength: 3

            transform: Rotation {
                id: backRotation
                origin.x: backSide.width / 2
                origin.y: backSide.height / 2
                axis { x: 0; y: 1; z: 0 }
                angle: -180

                Behavior on angle {
                    NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
                }
            }

            onConfirmed: function(value) {
                if (root.keypadCallback) {
                    root.keypadCallback(parseInt(value))
                }
                root.showKeypad = false
                backSide.clear()
            }

            onCancelled: {
                root.showKeypad = false
                backSide.clear()
            }
        }

        // 翻转动画状态
        states: [
            State {
                name: "showKeypad"
                when: showKeypad
                PropertyChanges { target: frontRotation; angle: 90 }
                PropertyChanges { target: backRotation; angle: 0 }
            },
            State {
                name: "showContent"
                when: !showKeypad
                PropertyChanges { target: frontRotation; angle: 0 }
                PropertyChanges { target: backRotation; angle: -180 }
            }
        ]
    }
    }

    // 取消打印确认对话框
    Dialog {
        id: cancelDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.5, Style.baseUnit * 20)
        modal: true

        background: Rectangle {
            color: Style.bgCard
            border.width: Style.borderMedium
            border.color: Style.divider
        }

        header: Rectangle {
            width: parent.width
            height: Style.baseUnit * 3
            color: Style.bgSecondary

            Label {
                anchors.centerIn: parent
                text: "CONFIRM CANCEL"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
            }
        }

        contentItem: Label {
            text: "Cancel current print job?\nThis action cannot be undone."
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textPrimary
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            padding: Style.spacingLarge
        }

        footer: Item {
            width: parent.width
            height: Style.baseUnit * 8

            Rectangle {
                anchors.fill: parent
                color: Style.bgSecondary

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingLarge
                    spacing: Style.spacingLarge

                    // NO 按钮
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Style.buttonHeightLarge
                        color: Style.bgCard
                        border.width: Style.borderMedium
                        border.color: Style.divider

                        Label {
                            anchors.centerIn: parent
                            text: "NO"
                            font.pixelSize: Style.fontXLarge
                            font.family: Style.fontFamily
                            font.bold: true
                            font.letterSpacing: 4
                            color: Style.textPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cancelDialog.reject()
                        }
                    }

                    // YES 按钮
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Style.buttonHeightLarge
                        color: Style.error
                        border.width: Style.borderMedium
                        border.color: Style.divider

                        Label {
                            anchors.centerIn: parent
                            text: "YES"
                            font.pixelSize: Style.fontXLarge
                            font.family: Style.fontFamily
                            font.bold: true
                            font.letterSpacing: 4
                            color: Style.textPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cancelDialog.accept()
                        }
                    }
                }
            }
        }

        onAccepted: {
            if (printer) printer.cancelPrint()
        }
    }

    // 辅助函数
    function adjustZOffset(delta) {
        if (!printer) return

        var gcode = "SET_GCODE_OFFSET Z_ADJUST=" + delta.toFixed(3) + " MOVE=1"
        sendGcode(gcode)
        console.log("Adjust Z offset:", delta)
    }

    function sendGcode(gcode) {
        if (!printer) {
            console.warn("Printer not connected")
            showError("Printer not connected")
            return
        }

        // 使用 WebSocket/JSON-RPC 发送 G-code
        printer.sendGcode(gcode)
        console.log("G-code sent via WebSocket:", gcode)
    }
}
