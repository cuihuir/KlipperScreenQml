import QtQuick
import QtQuick.Window
import QtQuick.Controls.Material

Window {
    id: window
    width: 1024
    height: 600
    visible: true
    title: "JobStatusPage Test"

    Material.theme: Material.Dark
    Material.accent: Material.Blue

    Loader {
        anchors.fill: parent
        source: "qml/pages/JobStatusPage.qml"

        onLoaded: {
            console.log("JobStatusPage loaded successfully")
            // Simulate some data
            item.currentState = "printing"
            item.currentProgress = 0.45
            item.printDuration = 1234
            item.currentFilename = "test_print.gcode"
            item.currentLayer = 45
            item.totalLayers = 100
            item.filamentUsed = 1234.5
        }
    }
}
