import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    // Properties
    property string title: ""
    property string status: "offline"  // "online", "offline", "ready", "printing", "error"

    // Metro style
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        spacing: Style.spacingSmall

        // Status dot
        Rectangle {
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            radius: 6
            color: getStatusColor()

            // Pulsing animation for active states
            SequentialAnimation {
                running: status === "printing" || status === "online"
                loops: Animation.Infinite

                PropertyAnimation {
                    target: root
                    property: "scale"
                    to: 1.2
                    duration: 1000
                }
                PropertyAnimation {
                    target: root
                    property: "scale"
                    to: 1.0
                    duration: 1000
                }
            }
        }

        // Status text
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.spacingXSmall

            Label {
                text: title
                font.pixelSize: Style.fontSmall
                font.family: Style.fontFamily
                color: Style.textSecondary
            }

            Label {
                text: getStatusText()
                font.pixelSize: Style.fontNormal
                font.family: Style.fontFamily
                font.bold: true
                color: getStatusColor()
            }
        }
    }

    // Functions
    function getStatusColor() {
        switch(status) {
            case "online":
            case "ready":
                return Style.success
            case "printing":
                return Style.info
            case "error":
                return Style.error
            case "offline":
            default:
                return Style.textDisabled
        }
    }

    function getStatusText() {
        switch(status) {
            case "online":
                return "在线"
            case "ready":
                return "就绪"
            case "printing":
                return "打印中"
            case "error":
                return "错误"
            case "offline":
            default:
                return "离线"
        }
    }
}