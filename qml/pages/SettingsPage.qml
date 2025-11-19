import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Metro风格设置页 - 完整功能
Page {
    id: root
    property var printer: null
    property var app: null

    signal showError(string message)

    background: Rectangle {
        color: Style.bgPrimary
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        clip: true

        ColumnLayout {
            width: parent.width - Style.spacingLarge * 2
            spacing: Style.spacingLarge

            // 打印机设置
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 12
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingMedium

                    Label {
                        text: "PRINTER CONNECTION"
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

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: Style.spacingMedium
                        columnSpacing: Style.spacingMedium

                        Label {
                            text: "IP ADDRESS"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            font.letterSpacing: 1
                            color: Style.textSecondary
                        }

                        TextField {
                            id: ipField
                            Layout.fillWidth: true
                            text: app ? app.printerHost : "192.168.200.209"
                            font.pixelSize: Style.fontNormal
                            font.family: Style.fontFamilyMono
                            color: Style.textPrimary

                            background: Rectangle {
                                color: Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider
                            }
                        }

                        Label {
                            text: "PORT"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            font.letterSpacing: 1
                            color: Style.textSecondary
                        }

                        TextField {
                            id: portField
                            Layout.fillWidth: true
                            text: app ? app.printerPort.toString() : "7125"
                            font.pixelSize: Style.fontNormal
                            font.family: Style.fontFamilyMono
                            color: Style.textPrimary

                            background: Rectangle {
                                color: Style.bgSecondary
                                border.width: Style.borderThin
                                border.color: Style.divider
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Style.buttonHeight
                        color: Style.info
                        border.width: Style.borderThin
                        border.color: Style.divider

                        Label {
                            anchors.centerIn: parent
                            text: "SAVE & RECONNECT"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            font.bold: true
                            font.letterSpacing: 2
                            color: Style.bgPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: saveConnection()
                        }
                    }
                }
            }

            // 系统信息
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 10
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingMedium

                    Label {
                        text: "SYSTEM INFO"
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

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: Style.spacingSmall
                        columnSpacing: Style.spacingLarge

                        Label {
                            text: "VERSION"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            font.letterSpacing: 1
                            color: Style.textSecondary
                        }
                        Label {
                            text: "QtKs v1.0.0"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamilyMono
                            font.bold: true
                            color: Style.accent
                        }

                        Label {
                            text: "FRAMEWORK"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            font.letterSpacing: 1
                            color: Style.textSecondary
                        }
                        Label {
                            text: "PySide6 + QML"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamilyMono
                            color: Style.textPrimary
                        }

                        Label {
                            text: "CONNECTION"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            font.letterSpacing: 1
                            color: Style.textSecondary
                        }
                        Label {
                            text: printer && printer.isConnected ? "ONLINE" : "OFFLINE"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamilyMono
                            font.bold: true
                            color: printer && printer.isConnected ? Style.success : Style.error
                        }

                        Label {
                            text: "PRINTER STATE"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamily
                            font.letterSpacing: 1
                            color: Style.textSecondary
                        }
                        Label {
                            text: printer ? printer.printerState.toUpperCase() : "UNKNOWN"
                            font.pixelSize: Style.fontSmall
                            font.family: Style.fontFamilyMono
                            font.bold: true
                            color: printer ? Style.getStateColor(printer.printerState) : Style.textDisabled
                        }
                    }
                }
            }

            // 系统操作
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 12
                color: Style.bgCard
                border.width: Style.borderThin
                border.color: Style.divider

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingMedium

                    Label {
                        text: "SYSTEM OPERATIONS"
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

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: Style.spacingSmall
                        columnSpacing: Style.spacingSmall

                        // 重启 GUI
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.buttonHeight
                            color: Style.info
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "RESTART GUI"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 1
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: restartDialog.open()
                            }
                        }

                        // 重启固件
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.buttonHeight
                            color: Style.warning
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "RESTART FIRMWARE"
                                font.pixelSize: Style.fontXSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 1
                                color: Style.bgPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: firmwareRestartDialog.open()
                            }
                        }

                        // 重启主机
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.buttonHeight
                            color: Style.error
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: "REBOOT HOST"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 1
                                color: Style.textPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: rebootDialog.open()
                            }
                        }

                        // 关机
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Style.buttonHeight
                            color: Style.error
                            border.width: Style.borderThick
                            border.color: Style.error

                            Label {
                                anchors.centerIn: parent
                                text: "SHUTDOWN"
                                font.pixelSize: Style.fontSmall
                                font.family: Style.fontFamily
                                font.bold: true
                                font.letterSpacing: 1
                                color: Style.textPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: shutdownDialog.open()
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // 重启 GUI 对话框
    Dialog {
        id: restartDialog
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
                text: "RESTART GUI"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
            }
        }

        contentItem: Label {
            text: "Restart the GUI interface?"
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
                text: "RESTART"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                background: Rectangle {
                    color: Style.info
                    border.width: Style.borderThin
                    border.color: Style.divider
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.bgPrimary
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

        onAccepted: Qt.quit()
    }

    // 其他确认对话框（固件重启、重启主机、关机）
    Dialog {
        id: firmwareRestartDialog
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
            color: Style.warning

            Label {
                anchors.centerIn: parent
                text: "RESTART FIRMWARE"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.bgPrimary
            }
        }

        contentItem: Label {
            text: "Restart Klipper firmware?"
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
                text: "RESTART"
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

                background: Rectangle {
                    color: Style.warning
                    border.width: Style.borderThin
                    border.color: Style.divider
                }

                contentItem: Label {
                    text: parent.text
                    font: parent.font
                    color: Style.bgPrimary
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

        onAccepted: sendGcode("FIRMWARE_RESTART")
    }

    Dialog {
        id: rebootDialog
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
                text: "REBOOT HOST"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
            }
        }

        contentItem: Label {
            text: "Reboot the host computer?\nThis will disconnect the GUI."
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
                text: "REBOOT"
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

        onAccepted: systemCommand("reboot")
    }

    Dialog {
        id: shutdownDialog
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
                text: "⚠ SHUTDOWN"
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
            }
        }

        contentItem: Label {
            text: "Shutdown the host computer?\nThis will power off the system."
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
                text: "SHUTDOWN"
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

        onAccepted: systemCommand("shutdown")
    }

    // 辅助函数
    function saveConnection() {
        var host = ipField.text.trim()
        var port = parseInt(portField.text)

        if (!host || port <= 0 || port > 65535) {
            console.error("Invalid IP or port:", host, port)
            return
        }

        console.log("Saving connection:", host, port)
        if (app) {
            app.saveConnectionAndReconnect(host, port)
        } else {
            console.error("App object not available")
        }
    }

    function sendGcode(gcode) {
        var xhr = new XMLHttpRequest()
        var url = "http://" + app.printerHost + ":" + app.printerPort + "/printer/gcode/script"
        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("Sent G-code:", gcode)
                } else {
                    console.error("G-code failed:", xhr.status)
                    showError("G-code command failed (HTTP " + xhr.status + ")")
                }
            }
        }

        xhr.send(JSON.stringify({ script: gcode }))
    }

    function systemCommand(command) {
        var xhr = new XMLHttpRequest()
        var url = "http://" + app.printerHost + ":" + app.printerPort + "/machine/" + command
        xhr.open("POST", url, true)

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("System command:", command)
                } else {
                    console.error("System command failed:", xhr.status)
                    showError("System command failed (HTTP " + xhr.status + ")")
                }
            }
        }

        xhr.send()
    }
}
