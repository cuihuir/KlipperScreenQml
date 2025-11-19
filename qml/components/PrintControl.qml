import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Metro风格打印控制面板
Rectangle {
    id: root

    property var printer: null

    color: Style.bgCard
    border.width: Style.borderThin
    border.color: Style.divider

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingMedium

        // 标题和进度
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "PRINT CONTROL"
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

        // 打印进度条 - Metro简洁风格
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

            // 进度文字覆盖
            Label {
                anchors.centerIn: parent
                text: printer && printer.printerState === "printing" ? "PRINTING..." : "IDLE"
                font.pixelSize: Style.fontXSmall
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 1
                color: Style.textPrimary
            }
        }

        // 控制按钮 - Metro扁平方块
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rows: 2
            rowSpacing: Style.spacingSmall
            columnSpacing: Style.spacingSmall

            // 暂停
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeight
                color: enabled ? Style.warning : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                enabled: printer && printer.printerState === "printing"
                opacity: enabled ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "PAUSE"
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: enabled ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    enabled: parent.enabled
                    onClicked: if (printer) printer.pausePrint()
                }
            }

            // 恢复
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeight
                color: enabled ? Style.success : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                enabled: printer && printer.printerState === "paused"
                opacity: enabled ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "RESUME"
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: enabled ? Style.bgPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    enabled: parent.enabled
                    onClicked: if (printer) printer.resumePrint()
                }
            }

            // 取消
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeight
                color: enabled ? Style.error : Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider
                enabled: printer && (printer.printerState === "printing" || printer.printerState === "paused")
                opacity: enabled ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "CANCEL"
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: enabled ? Style.textPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    enabled: parent.enabled
                    onClicked: confirmDialog.open()
                }
            }

            // 紧急停止
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeight
                color: enabled ? Style.error : Style.bgSecondary
                border.width: Style.borderThick
                border.color: Style.error
                enabled: printer && printer.isConnected
                opacity: enabled ? 1.0 : 0.5

                Label {
                    anchors.centerIn: parent
                    text: "E-STOP"
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    font.bold: true
                    font.letterSpacing: 2
                    color: enabled ? Style.textPrimary : Style.textDisabled
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    enabled: parent.enabled
                    onClicked: emergencyDialog.open()
                }

                // 危险闪烁
                SequentialAnimation on opacity {
                    running: enabled
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.7; duration: 800 }
                    NumberAnimation { from: 0.7; to: 1.0; duration: 800 }
                }
            }
        }
    }

    // 确认对话框
    Dialog {
        id: confirmDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.5, Style.baseUnit * 20)
        modal: true
        title: "CONFIRM CANCEL"

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

        footer: DialogButtonBox {
            background: Rectangle { color: Style.bgSecondary }

            Button {
                text: "YES"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                background: Rectangle {
                    color: Style.error
                    border.width: Style.borderThin
                    border.color: Style.divider
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "NO"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

                background: Rectangle {
                    color: Style.bgCard
                    border.width: Style.borderThin
                    border.color: Style.divider
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        onAccepted: {
            if (printer) printer.cancelPrint()
        }
    }

    // 紧急停止对话框
    Dialog {
        id: emergencyDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.5, Style.baseUnit * 20)
        modal: true

        background: Rectangle {
            color: Style.bgCard
            border.width: Style.borderThick
            border.color: Style.error
        }

        header: Rectangle {
            width: parent.width
            height: Style.baseUnit * 3
            color: Style.error

            Label {
                anchors.centerIn: parent
                text: "⚠ EMERGENCY STOP"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.bgPrimary
            }
        }

        contentItem: Label {
            text: "EMERGENCY STOP will immediately\nstop all motors!\n\nAre you sure?"
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            font.bold: true
            color: Style.error
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            padding: Style.spacingLarge
        }

        footer: DialogButtonBox {
            background: Rectangle { color: Style.bgSecondary }

            Button {
                text: "STOP NOW"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                background: Rectangle {
                    color: Style.error
                    border.width: Style.borderMedium
                    border.color: Style.error
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "CANCEL"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

                background: Rectangle {
                    color: Style.bgCard
                    border.width: Style.borderThin
                    border.color: Style.divider
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        onAccepted: {
            if (printer) printer.emergencyStop()
        }
    }
}
