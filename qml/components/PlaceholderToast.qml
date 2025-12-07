import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Popup {
    id: root

    property string message: ""

    // Auto-hide timer
    property int autoHideDelay: 3000

    // Show in center of screen
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    // Metro style toast
    width: Math.min(parent.width * 0.8, 400)
    height: 80
    padding: 0

    // Dark background with yellow accent for placeholders
    Rectangle {
        anchors.fill: parent
        color: Style.bgCard
        border.width: 2
        border.color: Style.accent
        radius: Style.radiusSmall

        // Content layout
        RowLayout {
            anchors.fill: parent
            anchors.margins: Style.spacingMedium
            spacing: Style.spacingMedium

            // Placeholder icon
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                color: Style.accent
                radius: 16

                Label {
                    anchors.centerIn: parent
                    text: "!"
                    font.pixelSize: Style.fontLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.bgPrimary
                }
            }

            // Message text
            Label {
                Layout.fillWidth: true
                text: root.message
                font.pixelSize: Style.fontNormal
                font.family: Style.fontFamily
                color: Style.textPrimary
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        // Progress bar at bottom
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 3
            color: Style.accent

            // Animated progress for auto-hide
            NumberAnimation on width {
                from: parent.width
                to: 0
                duration: root.autoHideDelay
                running: root.opened && root.visible
            }
        }
    }

    // Auto-hide timer
    Timer {
        id: autoHideTimer
        interval: root.autoHideDelay
        onTriggered: root.close()
    }

    // Show function
    function show(messageText: string) {
        root.message = messageText
        root.open()
        autoHideTimer.restart()
        console.log("Placeholder Toast:", messageText)
    }

    // Event handlers
    onOpened: {
        autoHideTimer.restart()
    }

    onClosed: {
        autoHideTimer.stop()
    }
}