import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: root

    property bool connected: false

    color: connected ? "#1B5E20" : "#B71C1C"
    radius: 8
    border.color: Qt.lighter(color, 1.3)
    border.width: 2

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // 连接指示灯
        Rectangle {
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            radius: 6
            color: connected ? "#4CAF50" : "#F44336"

            SequentialAnimation on opacity {
                running: !connected
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
            }
        }

        Label {
            Layout.fillWidth: true
            text: connected ? "已连接" : "未连接"
            font.pixelSize: 14
            font.bold: true
            color: "white"
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
