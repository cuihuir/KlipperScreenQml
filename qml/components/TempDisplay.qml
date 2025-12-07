import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Rectangle {
    id: root

    // Properties
    property string title: ""
    property real currentTemp: 0
    property real targetTemp: 0
    property bool visible: true

    // Metro style
    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.spacingXSmall

        // Title
        Label {
            Layout.fillWidth: true
            text: title
            font.pixelSize: Style.fontSmall
            font.family: Style.fontFamily
            color: Style.textSecondary
            horizontalAlignment: Text.AlignHCenter
        }

        // Current temperature
        Label {
            Layout.fillWidth: true
            text: currentTemp.toFixed(1) + "°C"
            font.pixelSize: Style.fontXLarge
            font.family: Style.fontFamilyMono
            font.bold: true
            color: Style.getTempColor(currentTemp, 250)
            horizontalAlignment: Text.AlignHCenter
        }

        // Target temperature (if set)
        Label {
            Layout.fillWidth: true
            text: targetTemp > 0 ? "→ " + targetTemp.toFixed(0) + "°C" : ""
            font.pixelSize: Style.fontSmall
            font.family: Style.fontFamilyMono
            color: targetTemp > 0 ? Style.accent : "transparent"
            horizontalAlignment: Text.AlignHCenter
            visible: targetTemp > 0
        }
    }

    // Touch feedback
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Could open temperature setting dialog here
        }
    }
}