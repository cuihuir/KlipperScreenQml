// Circular Progress Indicator
// 圆形进度指示器
import QtQuick
import QtQuick.Controls.Material
import ".."

Item {
    id: root

    // Public properties
    property real progress: 0.0  // 0.0 to 1.0
    property string progressText: ""
    property color backgroundColor: Qt.rgba(0.13, 0.13, 0.13, 1.0)
    property color progressColor: Material.accent
    property real lineWidth: 12

    implicitWidth: 200
    implicitHeight: 200

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            var centerX = width / 2
            var centerY = height / 2
            var radius = Math.min(width, height) * 0.42

            ctx.clearRect(0, 0, width, height)

            // Draw background circle
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
            ctx.lineWidth = root.lineWidth
            ctx.strokeStyle = root.backgroundColor
            ctx.stroke()

            // Draw progress arc
            if (root.progress > 0) {
                ctx.beginPath()
                var startAngle = -Math.PI / 2  // Start from top (12 o'clock)
                var endAngle = startAngle + (root.progress * Math.PI * 2)
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.lineWidth = root.lineWidth
                ctx.strokeStyle = root.progressColor
                ctx.lineCap = "round"
                ctx.stroke()
            }
        }
    }

    // Progress text in center
    Label {
        anchors.centerIn: parent
        text: root.progressText || Math.floor(root.progress * 100) + "%"
        font.pixelSize: Math.min(root.width, root.height) * 0.2
        font.bold: true
        color: Material.foreground
    }

    // Redraw when progress changes
    onProgressChanged: canvas.requestPaint()
    onBackgroundColorChanged: canvas.requestPaint()
    onProgressColorChanged: canvas.requestPaint()
    onLineWidthChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
}
