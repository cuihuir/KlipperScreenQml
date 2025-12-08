// Confirm Dialog Component
// 确认对话框组件
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import ".."

Dialog {
    id: root

    // Public properties
    property string dialogTitle: "确认"
    property string dialogMessage: "确定要执行此操作吗？"
    property string confirmText: "确定"
    property string cancelText: "取消"

    // Note: accepted/rejected signals already exist in Dialog

    modal: true
    anchors.centerIn: parent
    width: Math.min(parent.width * 0.8, 400)
    title: dialogTitle

    Material.background: Style.bgCard

    header: Rectangle {
        color: Style.bgCard
        height: 60

        Label {
            anchors.centerIn: parent
            text: root.dialogTitle
            font.pixelSize: 18
            font.bold: true
            color: Material.accent
        }
    }

    contentItem: Rectangle {
        color: Style.bgCard
        implicitHeight: messageLabel.height + 40

        Label {
            id: messageLabel
            anchors.centerIn: parent
            width: parent.width - 40
            text: root.dialogMessage
            font.pixelSize: 14
            color: Style.textPrimary
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    footer: Rectangle {
        color: Style.bgCard
        height: 80

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            // Cancel button
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: root.cancelText
                font.pixelSize: 14
                Material.background: Style.bgSecondary
                onClicked: {
                    root.rejected()
                    root.close()
                }
            }

            // Confirm button
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: root.confirmText
                font.pixelSize: 14
                Material.background: Material.accent
                onClicked: {
                    root.accepted()
                    root.close()
                }
            }
        }
    }
}
