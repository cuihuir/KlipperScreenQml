import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Popup {
    id: root

    // Dialog properties
    property string title: "确认操作"
    property string message: "确定要执行此操作吗？"
    property string confirmText: "确定"
    property string cancelText: "取消"
    property var onConfirmed: function() {}

    // Show in center of screen
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    // Metro style dialog
    width: Math.min(parent.width * 0.9, 500)
    height: Math.min(parent.height * 0.8, 300)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Dark background overlay
    Rectangle {
        anchors.fill: parent
        color: Style.bgCard
        border.width: 2
        border.color: Style.accent
        radius: Style.radiusSmall

        // Content layout
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.spacingLarge
            spacing: Style.spacingLarge

            // Title
            Label {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Style.fontLarge
                font.family: Style.fontFamily
                font.bold: true
                color: Style.textPrimary
                wrapMode: Text.WordWrap
            }

            // Message
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.message
                font.pixelSize: Style.fontNormal
                font.family: Style.fontFamily
                color: Style.textSecondary
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacingMedium

                // Cancel button (secondary)
                MetroButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    text: root.cancelText
                    backgroundColor: Style.bgSecondary
                    textColor: Style.textPrimary
                    onClicked: root.close()
                }

                // Confirm button (primary)
                MetroButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    text: root.confirmText
                    backgroundColor: Style.accent
                    textColor: Style.bgPrimary
                    onClicked: {
                        root.onConfirmed()
                        root.close()
                    }
                }
            }
        }
    }

    // Show function
    function show(titleText: string, messageText: string, confirmCallback: function) {
        root.title = titleText
        root.message = messageText
        root.onConfirmed = confirmCallback || function() {}
        root.open()
    }
}