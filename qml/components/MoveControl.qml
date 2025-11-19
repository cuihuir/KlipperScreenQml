import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: root

    property var printer: null

    color: "#2d2d2d"
    radius: 12
    border.color: "#404040"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // 标题
        Label {
            text: "移动控制"
            font.pixelSize: 20
            font.bold: true
            color: Material.accent
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#404040"
        }

        // XY 控制
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 200

            // 中心位置
            Rectangle {
                id: centerCircle
                anchors.centerIn: parent
                width: 60
                height: 60
                radius: 30
                color: "#424242"
                border.color: Material.accent
                border.width: 2

                Label {
                    anchors.centerIn: parent
                    text: "原点"
                    font.pixelSize: 12
                    opacity: 0.7
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: homeXY()
                }
            }

            // Y+ (前)
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 50
                height: 50
                text: "▲\nY+"
                font.pixelSize: 10
                Material.background: "#424242"
                onClicked: moveY(getMoveDistance())
            }

            // Y- (后)
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: 50
                height: 50
                text: "▼\nY-"
                font.pixelSize: 10
                Material.background: "#424242"
                onClicked: moveY(-getMoveDistance())
            }

            // X- (左)
            Button {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: 50
                height: 50
                text: "◄\nX-"
                font.pixelSize: 10
                Material.background: "#424242"
                onClicked: moveX(-getMoveDistance())
            }

            // X+ (右)
            Button {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: 50
                height: 50
                text: "►\nX+"
                font.pixelSize: 10
                Material.background: "#424242"
                onClicked: moveX(getMoveDistance())
            }
        }

        // Z 控制
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Z 轴:"
                font.pixelSize: 14
            }

            Button {
                text: "▲ Z+10"
                Layout.fillWidth: true
                Material.background: "#424242"
                onClicked: moveZ(10)
            }

            Button {
                text: "▲ Z+1"
                Layout.fillWidth: true
                Material.background: "#424242"
                onClicked: moveZ(1)
            }

            Button {
                text: "▼ Z-1"
                Layout.fillWidth: true
                Material.background: "#424242"
                onClicked: moveZ(-1)
            }

            Button {
                text: "▼ Z-10"
                Layout.fillWidth: true
                Material.background: "#424242"
                onClicked: moveZ(-10)
            }
        }

        // 移动距离选择
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "步进:"
                font.pixelSize: 14
            }

            ButtonGroup {
                id: distanceGroup
                exclusive: true
            }

            Repeater {
                model: [0.1, 1, 10, 50, 100]

                Button {
                    text: modelData + "mm"
                    checkable: true
                    checked: modelData === 10
                    ButtonGroup.group: distanceGroup
                    Layout.fillWidth: true
                    Material.background: checked ? Material.accent : "#424242"
                    font.pixelSize: 12

                    property real distance: modelData
                }
            }
        }

        // 归零按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "归零 X"
                Layout.fillWidth: true
                Material.background: "#FF9800"
                onClicked: homeAxis("X")
            }

            Button {
                text: "归零 Y"
                Layout.fillWidth: true
                Material.background: "#FF9800"
                onClicked: homeAxis("Y")
            }

            Button {
                text: "归零 Z"
                Layout.fillWidth: true
                Material.background: "#FF9800"
                onClicked: homeAxis("Z")
            }

            Button {
                text: "全部归零"
                Layout.fillWidth: true
                Material.background: "#F44336"
                onClicked: homeAll()
            }
        }

        // 电机控制
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "禁用电机"
                Layout.fillWidth: true
                Material.background: "#9C27B0"
                onClicked: disableMotors()
            }

            Button {
                text: "Z 探针"
                Layout.fillWidth: true
                Material.background: "#2196F3"
                onClicked: probeZ()
            }
        }
    }

    // 辅助函数
    function getMoveDistance() {
        var checkedButton = distanceGroup.checkedButton
        return checkedButton ? checkedButton.distance : 10
    }

    function moveX(distance) {
        if (!printer) return
        var gcode = `G91\nG1 X${distance} F3000\nG90`
        sendGcode(gcode)
        console.log(`移动 X 轴: ${distance}mm`)
    }

    function moveY(distance) {
        if (!printer) return
        var gcode = `G91\nG1 Y${distance} F3000\nG90`
        sendGcode(gcode)
        console.log(`移动 Y 轴: ${distance}mm`)
    }

    function moveZ(distance) {
        if (!printer) return
        var gcode = `G91\nG1 Z${distance} F600\nG90`
        sendGcode(gcode)
        console.log(`移动 Z 轴: ${distance}mm`)
    }

    function homeXY() {
        if (!printer) return
        sendGcode("G28 X Y")
        console.log("归零 XY")
    }

    function homeAxis(axis) {
        if (!printer) return
        sendGcode(`G28 ${axis}`)
        console.log(`归零 ${axis}`)
    }

    function homeAll() {
        if (!printer) return
        sendGcode("G28")
        console.log("全部归零")
    }

    function disableMotors() {
        if (!printer) return
        sendGcode("M84")
        console.log("禁用电机")
    }

    function probeZ() {
        if (!printer) return
        sendGcode("PROBE")
        console.log("Z 探针")
    }

    function sendGcode(gcode) {
        if (!printer) {
            console.error("打印机未连接")
            return
        }

        // 使用 Python 后端发送 G-code
        var xhr = new XMLHttpRequest()
        var url = "http://192.168.200.209:7125/printer/gcode/script"

        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-Type", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    console.log("G-code 发送成功:", gcode)
                } else {
                    console.error("G-code 发送失败:", xhr.status)
                }
            }
        }

        var data = JSON.stringify({ script: gcode })
        xhr.send(data)
    }
}
