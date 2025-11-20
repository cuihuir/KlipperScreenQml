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
                id: topCard
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
                    sourceComponent: topCard.hasError ? errorComponent : (isPrinting ? printingComponent : welcomeComponent)
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

                    RowLayout {
                        anchors.fill: parent
                        spacing: Style.spacingLarge

                        // 左侧 - 打印机图片容器
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width * 0.4

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -parent.height * 0.1  // 向上偏移 10%
                                width: parent.width
                                height: parent.height * 0.8  // 缩小到 80% 高度
                                source: Qt.resolvedUrl("../assets/printer.png")
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                cache: false

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        console.error("Failed to load printer image:", source)
                                    }
                                }
                            }
                        }

                        // 右侧 - 文字信息
                        ColumnLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            spacing: Style.spacingMedium

                            Item { Layout.fillHeight: true }

                            Label {
                                Layout.fillWidth: true
                                text: "WELCOME TO QTKS"
                                font.pixelSize: Style.fontXXLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 4
                                color: Style.accent
                                wrapMode: Text.WordWrap
                            }

                            Label {
                                Layout.fillWidth: true
                                text: "Modern 3D Printer Interface"
                                font.pixelSize: Style.fontLarge
                                font.family: Style.fontFamily
                                font.letterSpacing: 2
                                color: Style.textSecondary
                                wrapMode: Text.WordWrap
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: Style.borderMedium
                                color: Style.accent
                            }

                            Label {
                                Layout.fillWidth: true
                                text: "Metro Design • High Performance\nOptimized for Touch Screens"
                                font.pixelSize: Style.fontNormal
                                font.family: Style.fontFamily
                                color: Style.textSecondary
                                wrapMode: Text.WordWrap
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }

                // 打印状态 - 缩略图和统计信息
                Component {
                    id: printingComponent

                    RowLayout {
                        anchors.fill: parent
                        spacing: Style.spacingLarge

                        // 左侧 - G-code 缩略图
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width * 0.4

                            Rectangle {
                                anchors.fill: parent
                                color: Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider

                                // 缩略图（如果有的话）
                                Image {
                                    visible: printer && printer.printThumbnail !== ""
                                    anchors.centerIn: parent
                                    width: parent.width * 0.9
                                    height: parent.height * 0.9
                                    source: printer ? printer.printThumbnail : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }

                                // 占位文字（无缩略图时显示）
                                Label {
                                    visible: !printer || printer.printThumbnail === ""
                                    anchors.centerIn: parent
                                    text: "G-CODE\nTHUMBNAIL"
                                    font.pixelSize: Style.fontLarge
                                    font.family: Style.fontFamily
                                    font.letterSpacing: 2
                                    color: Style.textDisabled
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // 右侧 - 打印统计信息
                        ColumnLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            spacing: Style.spacingMedium

                            Label {
                                text: "PRINTING"
                                font.pixelSize: Style.fontLarge
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 3
                                color: Style.accent
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: Style.borderMedium
                                color: Style.accent
                            }

                            // 文件名
                            Label {
                                Layout.fillWidth: true
                                text: printer ? (printer.printFilename || "NONE") : "NONE"
                                font.pixelSize: Style.fontNormal
                                font.family: Style.fontFamilyMono
                                color: Style.textPrimary
                                elide: Text.ElideMiddle
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 2
                            }

                            Item { height: Style.spacingSmall }

                            // 两列布局显示所有指标
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Style.spacingLarge

                                // 左列
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Style.spacingSmall

                                    // 打印速度
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "打印速度:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: printer ? (printer.liveVelocity.toFixed(1) + " mm/s") : "0 mm/s"
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.textPrimary
                                        }
                                    }

                                    // 流量
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "流量:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: printer ? (printer.liveFlow.toFixed(1) + " mm³/s") : "0 mm³/s"
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.textPrimary
                                        }
                                    }

                                    // 耗材用量
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "耗材用量:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: printer ? ((printer.filamentUsed / 1000).toFixed(2) + " m") : "0 m"
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.textPrimary
                                        }
                                    }

                                    // 打印层
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "打印层:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: printer ? (printer.currentLayer + " of " + printer.totalLayers) : "0 of 0"
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.info
                                            font.bold: true
                                        }
                                    }
                                }

                                // 右列
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Style.spacingSmall

                                    // 估算剩余
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "估算剩余:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: {
                                                if (!printer || printer.fileTimeLeft <= 0) return "--:--:--"
                                                var seconds = Math.floor(printer.fileTimeLeft)
                                                var h = Math.floor(seconds / 3600)
                                                var m = Math.floor((seconds % 3600) / 60)
                                                var s = seconds % 60
                                                return (h < 10 ? "0" : "") + h + ":" +
                                                       (m < 10 ? "0" : "") + m + ":" +
                                                       (s < 10 ? "0" : "") + s
                                            }
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.textPrimary
                                        }
                                    }

                                    // 切片剩余
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "切片剩余:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: {
                                                if (!printer || printer.slicerTimeLeft <= 0) return "--:--:--"
                                                var seconds = Math.floor(printer.slicerTimeLeft)
                                                var h = Math.floor(seconds / 3600)
                                                var m = Math.floor((seconds % 3600) / 60)
                                                var s = seconds % 60
                                                return (h < 10 ? "0" : "") + h + ":" +
                                                       (m < 10 ? "0" : "") + m + ":" +
                                                       (s < 10 ? "0" : "") + s
                                            }
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.textPrimary
                                        }
                                    }

                                    // 合计
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "合计:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: {
                                                if (!printer) return "00:00:00"
                                                var seconds = Math.floor(printer.printDuration)
                                                var h = Math.floor(seconds / 3600)
                                                var m = Math.floor((seconds % 3600) / 60)
                                                var s = seconds % 60
                                                return (h < 10 ? "0" : "") + h + ":" +
                                                       (m < 10 ? "0" : "") + m + ":" +
                                                       (s < 10 ? "0" : "") + s
                                            }
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.accent
                                            font.bold: true
                                        }
                                    }

                                    // 预估完成
                                    RowLayout {
                                        spacing: Style.spacingSmall
                                        Label {
                                            text: "预估完成:"
                                            font.pixelSize: Style.fontSmall
                                            color: Style.textSecondary
                                        }
                                        Label {
                                            text: {
                                                if (!printer || printer.etaTimestamp <= 0) return "--:--"
                                                var date = new Date(printer.etaTimestamp)
                                                var h = date.getHours()
                                                var m = date.getMinutes()
                                                return (h < 10 ? "0" : "") + h + ":" +
                                                       (m < 10 ? "0" : "") + m
                                            }
                                            font.pixelSize: Style.fontNormal
                                            font.family: Style.fontFamilyMono
                                            color: Style.textPrimary
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }
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
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !isPrinting
                        color: Style.info
                        border.width: Style.borderMedium
                        border.color: Style.divider

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Style.spacingMedium
                            spacing: Style.spacingLarge

                            // 左侧 - 3DBenchy 图片（水平翻转向左）
                            Item {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width * 0.35

                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: -parent.height * 0.25  // 大胆向上偏移 25%
                                    width: parent.width * 0.9
                                    height: parent.height * 0.7
                                    source: Qt.resolvedUrl("../assets/example-print.png")
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    cache: false
                                    mirror: true   // 水平镜像翻转（向左）

                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            console.error("Failed to load example print image:", source)
                                        }
                                    }
                                }
                            }

                            // 右侧 - START PRINT 文字
                            ColumnLayout {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                spacing: Style.spacingMedium

                                Item { Layout.fillHeight: true }

                                Label {
                                    Layout.fillWidth: true
                                    text: "START PRINT"
                                    font.pixelSize: Style.fontXXLarge
                                    font.family: Style.fontFamily
                                    font.bold: true
                                    font.letterSpacing: 5
                                    color: Style.bgPrimary
                                    wrapMode: Text.WordWrap
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: Style.borderThick
                                    color: Style.bgPrimary
                                }

                                Label {
                                    Layout.fillWidth: true
                                    text: "Select a G-code file\nto begin printing"
                                    font.pixelSize: Style.fontLarge
                                    font.family: Style.fontFamily
                                    color: Style.bgPrimary
                                    wrapMode: Text.WordWrap
                                }

                                Item { Layout.fillHeight: true }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.navigateToFiles()
                        }
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
