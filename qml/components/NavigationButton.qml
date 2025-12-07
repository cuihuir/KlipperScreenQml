import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    // Properties
    property string pageName: ""
    property string icon: ""
    property string text: ""
    property bool isCurrentPage: false

    // Minimum touch target 80px×80px
    implicitHeight: 80
    implicitWidth: 80

    // Metro style: flat design with state-based colors
    color: isCurrentPage ? Style.accent : "transparent"

    // Active indicator (top border for current page)
    Rectangle {
        id: activeIndicator
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 4
        color: Style.accent
        visible: isCurrentPage
    }

    // Hover effect background
    Rectangle {
        anchors.fill: parent
        color: Style.textPrimary
        opacity: mouseArea.containsMouse && !isCurrentPage ? 0.05 : 0
        z: -1

        Behavior on opacity {
            NumberAnimation { duration: Style.durationFast }
        }
    }

    // Content layout
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingXSmall

        // Icon label
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: icon
            font.pixelSize: Style.fontMedium
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 2
            color: isCurrentPage ? Style.bgPrimary : Style.textPrimary
        }

        // Text label
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: text
            font.pixelSize: Style.fontXSmall
            font.family: Style.fontFamily
            color: isCurrentPage ? Style.bgPrimary : Style.textSecondary
        }
    }

    // Mouse interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()
        }
    }

    // Press animation
    SequentialAnimation {
        id: pressAnimation
        PropertyAnimation {
            target: root
            property: "scale"
            to: 0.95
            duration: 50
        }
        PropertyAnimation {
            target: root
            property: "scale"
            to: 1.0
            duration: 100
        }
    }

    onPressed: pressAnimation.start()
}