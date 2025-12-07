import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    // Properties
    property string currentPage: "home"
    signal pageSelected(string pageName)

    // Height fixed for touch targets (80px minimum)
    height: 80

    // Metro style: dark background with subtle border
    color: Style.bgSecondary
    border.width: 1
    border.color: Style.border

    // 4-button navigation layout
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 0

        // Home button
        NavigationButton {
            id: homeBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            pageName: "home"
            icon: "HOME"
            text: "首页"
            isCurrentPage: root.currentPage === "home"
            onClicked: root.pageSelected("home")
        }

        // Control button
        NavigationButton {
            id: controlBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            pageName: "control"
            icon: "MOVE"
            text: "控制"
            isCurrentPage: root.currentPage === "control"
            onClicked: root.pageSelected("control")
        }

        // Files button
        NavigationButton {
            id: filesBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            pageName: "files"
            icon: "FILES"
            text: "文件"
            isCurrentPage: root.currentPage === "files"
            onClicked: root.pageSelected("files")
        }

        // Settings button
        NavigationButton {
            id: settingsBtn
            Layout.fillWidth: true
            Layout.fillHeight: true
            pageName: "settings"
            icon: "CONFIG"
            text: "设置"
            isCurrentPage: root.currentPage === "settings"
            onClicked: root.pageSelected("settings")
        }
    }
}