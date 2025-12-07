// Job Status Page - Print Status Detail
// 打印状态详情页
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import ".."
import "../components" as Components

Page {
    id: root

    property var printer: null
    property string currentState: "standby"  // printing, paused, complete, cancelled, error, standby
    property string currentFilename: ""
    property real currentProgress: 0.0

    // Data cache
    property real printDuration: 0.0
    property real filamentUsed: 0.0
    property int currentLayer: 0
    property int totalLayers: 0
    property real extrudeFactor: 1.0
    property real speedFactor: 1.0
    property real liveVelocity: 0.0
    property real requestedSpeed: 0.0
    property real zPosition: 0.0
    property real zOffset: 0.0
    property real fanSpeed: 0.0
    property real flowrate: 0.0

    background: Rectangle {
        color: Style.bgPrimary
    }

    // Connections to MoonrakerClient signals
    Connections {
        target: printer

        // Print stats update
        function onPrintStatsUpdated(stats) {
            console.log("JobStatusPage: printStatsUpdated", typeof stats, stats)
            var data = (typeof stats === 'string') ? JSON.parse(stats) : stats
            if (data.state) {
                updatePrintState(data.state)
            }
            if (data.filename) {
                currentFilename = data.filename
                filenameLabel.text = data.filename
            }
            if (data.print_duration !== undefined) {
                printDuration = data.print_duration
                elapsedLabel.text = formatTime(printDuration)
            }
            if (data.filament_used !== undefined) {
                filamentUsed = data.filament_used
                filamentUsedLabel.text = (filamentUsed / 1000).toFixed(1) + " m"
            }
            if (data.info) {
                if (data.info.current_layer !== undefined) currentLayer = data.info.current_layer
                if (data.info.total_layer !== undefined) totalLayers = data.info.total_layer
                layerLabel.text = currentLayer + " / " + totalLayers
            }
        }

        // Print progress update
        function onPrintProgressChanged(progress) {
            console.log("JobStatusPage: printProgressChanged", typeof progress, progress)
            var data = (typeof progress === 'string') ? JSON.parse(progress) : progress
            if (data.progress !== undefined) {
                currentProgress = data.progress
                circularProgress.progress = currentProgress
                console.log("Updated progress to:", currentProgress)
            }
        }

        // Temperature update
        function onTemperatureUpdated(temps) {
            var data = (typeof temps === 'string') ? JSON.parse(temps) : temps
            // Update temperature buttons for all heaters
            for (var key in data) {
                if (data.hasOwnProperty(key)) {
                    var temp = data[key]
                    if (temp.temperature !== undefined && temp.target !== undefined) {
                        updateTemperatureButton(key, temp.temperature, temp.target, temp.power || 0)
                    }
                }
            }
        }

        // Position update
        function onPositionUpdated(pos) {
            var data = (typeof pos === 'string') ? JSON.parse(pos) : pos
            if (data.gcode_position) {
                zPosition = data.gcode_position[2] || 0
                zPosLabel.text = zPosition.toFixed(2) + " mm"
            }
            if (data.homing_origin) {
                zOffset = data.homing_origin[2] || 0
                zOffsetLabel.text = zOffset.toFixed(3) + " mm"
            }
            if (data.extrude_factor !== undefined) {
                extrudeFactor = data.extrude_factor
                extrudeFactorLabel.text = Math.round(extrudeFactor * 100) + "%"
            }
            if (data.speed_factor !== undefined) {
                speedFactor = data.speed_factor
                speedFactorLabel.text = Math.round(speedFactor * 100) + "%"
            }
            if (data.speed !== undefined) {
                requestedSpeed = data.speed / 60 * speedFactor
            }
            // Update combined speed display
            var speedText = Math.round(speedFactor * 100) + "% " +
                          liveVelocity.toFixed(0) + "/" + requestedSpeed.toFixed(0) + " mm/s"
            speedLabel.text = speedText
        }

        // Fan state change
        function onFanStateChanged(fanName, isOn, speed) {
            if (fanName === "fan") {  // Print cooling fan
                fanSpeed = speed
                fanSpeedLabel.text = Math.round(speed * 100) + "%"
            }
        }

        // Klipper error
        function onKlipperError(message) {
            currentState = "error"
            lcdMessageLabel.text = message
            lcdMessageLabel.visible = true
        }

        // Printer state change
        function onPrinterStateChanged(state) {
            updatePrintState(state)
        }
    }

    // Flow rate calculation timer (every 2 seconds)
    Timer {
        id: flowRateTimer
        interval: 2000
        running: currentState === "printing"
        repeat: true
        onTriggered: {
            // TODO: Calculate flow rate from live_extruder_velocity
            // flowrate = fila_section * live_extruder_velocity
            // For now, use a placeholder
            flowrateLabel.text = flowrate.toFixed(1) + " mm³/s"
        }
    }

    // Time left calculation timer
    Timer {
        id: timeLeftTimer
        interval: 1000
        running: currentState === "printing" || currentState === "paused"
        repeat: true
        onTriggered: {
            updateTimeLeft()
        }
    }

    // Main content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Top section: 3-column layout (info | progress | temperature)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20

            // Left column: Info displays
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 400
                spacing: 15

                // File info section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: Style.bgCard
                    radius: Style.radiusSmall
                    border.color: Style.border
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8

                        Label {
                            id: filenameLabel
                            text: "未选择文件"
                            font.pixelSize: 16
                            font.bold: true
                            color: Material.accent
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }

                        Label {
                            id: lcdMessageLabel
                            text: ""
                            font.pixelSize: 12
                            opacity: 0.7
                            visible: text !== ""
                            Layout.fillWidth: true
                        }
                    }
                }

                // Time info section
                Rectangle {
                    id: timeInfoRect
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgCard
                    radius: Style.radiusSmall
                    border.color: Style.border
                    border.width: 1

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10

                        // Elapsed time
                        Label {
                            text: "已用时间:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: elapsedLabel
                            text: "00:00:00"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Time left
                        Label {
                            text: "剩余时间:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: timeLeftLabel
                            text: "--:--:--"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Estimated time
                        Label {
                            text: "预计总时:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: estTimeLabel
                            text: "--:--:--"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Current layer
                        Label {
                            text: "当前层:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: layerLabel
                            text: "0 / 0"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Filament used
                        Label {
                            text: "已用耗材:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: filamentUsedLabel
                            text: "0.0 m"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                }

                // Extrusion/Speed info section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgCard
                    radius: Style.radiusSmall
                    border.color: Style.border
                    border.width: 1

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10

                        // Extrude factor
                        Label {
                            text: "挤出倍率:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: extrudeFactorLabel
                            text: "100%"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Speed factor
                        Label {
                            text: "速度倍率:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: speedFactorLabel
                            text: "100%"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Flow rate
                        Label {
                            text: "流量:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: flowrateLabel
                            text: "0.0 mm³/s"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Speed
                        Label {
                            text: "速度:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: speedLabel
                            text: "0 / 0 mm/s"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Z position
                        Label {
                            text: "Z 位置:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: zPosLabel
                            text: "0.00 mm"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Z offset
                        Label {
                            text: "Z 偏移:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: zOffsetLabel
                            text: "0.000 mm"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        // Fan speed
                        Label {
                            text: "风扇:"
                            font.pixelSize: 14
                            opacity: 0.7
                        }
                        Label {
                            id: fanSpeedLabel
                            text: "0%"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                }
            }

            // Center column: Progress circle + thumbnail
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 300
                spacing: 20

                // Circular progress
                Components.CircularProgress {
                    id: circularProgress
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 250
                    progress: 0.0
                    lineWidth: 15
                }

                // Thumbnail
                Rectangle {
                    id: thumbnailRect
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgCard
                    radius: Style.radiusSmall
                    border.color: Style.border
                    border.width: 1

                    Image {
                        id: thumbnailImage
                        anchors.fill: parent
                        anchors.margins: 10
                        fillMode: Image.PreserveAspectFit
                        source: ""
                        visible: status === Image.Ready

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showFullscreenThumbnail()
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: "无缩略图"
                        opacity: 0.5
                        visible: thumbnailImage.status !== Image.Ready
                    }
                }
            }

            // Right column: Temperature buttons
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 300
                spacing: 10

                Label {
                    text: "温度控制"
                    font.pixelSize: 16
                    font.bold: true
                    color: Material.accent
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        id: tempButtonsLayout
                        width: parent.width
                        spacing: 10

                        // Extruders
                        Repeater {
                            id: extruderRepeater
                            model: ListModel { id: extruderModel }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                text: model.label
                                font.pixelSize: 13
                                Material.background: model.isActive ? Material.accent : "#424242"

                                contentItem: ColumnLayout {
                                    spacing: 2
                                    Label {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: model.name
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    Label {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: model.label
                                        font.pixelSize: 14
                                    }
                                }

                                onClicked: navigateToTemperature(model.name)
                            }
                        }

                        // Heaters
                        Repeater {
                            id: heaterRepeater
                            model: ListModel { id: heaterModel }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                text: model.label
                                font.pixelSize: 13
                                Material.background: "#424242"

                                contentItem: ColumnLayout {
                                    spacing: 2
                                    Label {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: model.name
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    Label {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: model.label
                                        font.pixelSize: 14
                                    }
                                }

                                onClicked: navigateToTemperature(model.name)
                            }
                        }
                    }
                }
            }
        }

        // Bottom section: Control buttons
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Style.bgCard
            radius: Style.radiusSmall
            border.color: Style.border
            border.width: 1

            RowLayout {
                id: buttonRow
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Buttons will be dynamically changed based on state
                Button {
                    id: pauseButton
                    text: "暂停"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.background: Material.accent
                    font.pixelSize: 16
                    visible: currentState === "printing"
                    onClicked: pausePrint()
                }

                Button {
                    id: resumeButton
                    text: "继续"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.background: Material.Green
                    font.pixelSize: 16
                    visible: currentState === "paused"
                    onClicked: resumePrint()
                }

                Button {
                    id: cancelButton
                    text: "取消"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.background: Material.Red
                    font.pixelSize: 16
                    visible: currentState === "printing" || currentState === "paused"
                    onClicked: showCancelDialog()
                }

                Button {
                    id: fineTuneButton
                    text: "微调"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.background: "#FF9800"
                    font.pixelSize: 16
                    visible: currentState === "printing" || currentState === "paused"
                    onClicked: navigateToFineTune()
                }

                Button {
                    id: controlButton
                    text: "控制"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.background: "#2196F3"
                    font.pixelSize: 16
                    visible: currentState === "printing" || currentState === "paused"
                    onClicked: navigateToControl()
                }

                Button {
                    id: restartButton
                    text: "重新打印"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.background: Material.Green
                    font.pixelSize: 16
                    visible: currentState === "complete" || currentState === "cancelled" || currentState === "error"
                    onClicked: restartPrint()
                }

                Button {
                    id: menuButton
                    text: "菜单"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Material.background: "#9C27B0"
                    font.pixelSize: 16
                    visible: currentState !== "printing" && currentState !== "paused" && currentState !== "cancelling"
                    onClicked: navigateToMenu()
                }
            }
        }
    }

    // Confirm dialog for cancel
    Components.ConfirmDialog {
        id: cancelDialog
        dialogTitle: "取消打印"
        dialogMessage: "确定要取消当前打印吗？"
        onAccepted: cancelPrint()
    }

    // Functions
    function pausePrint() {
        if (!printer) return
        console.log("暂停打印")
        ApiClient.post("/printer/print/pause", {})
    }

    function resumePrint() {
        if (!printer) return
        console.log("继续打印")
        ApiClient.post("/printer/print/resume", {})
    }

    function cancelPrint() {
        if (!printer) return
        console.log("取消打印")
        currentState = "cancelling"
        ApiClient.post("/printer/print/cancel", {})
    }

    function restartPrint() {
        if (!printer) return
        console.log("重新打印")
        // TODO: Implement restart logic
    }

    function showCancelDialog() {
        cancelDialog.open()
    }

    function navigateToFineTune() {
        // TODO: Navigate to fine tune page
        console.log("Navigate to fine tune")
    }

    function navigateToControl() {
        // TODO: Navigate to control page
        console.log("Navigate to control")
    }

    function navigateToMenu() {
        // TODO: Navigate to main menu
        console.log("Navigate to menu")
    }

    function showFullscreenThumbnail() {
        // TODO: Show fullscreen thumbnail dialog
        console.log("Show fullscreen thumbnail")
    }

    function formatTime(seconds) {
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        var s = Math.floor(seconds % 60)
        return (h < 10 ? "0" + h : h) + ":" +
               (m < 10 ? "0" + m : m) + ":" +
               (s < 10 ? "0" + s : s)
    }

    function initTemperatureButtons() {
        if (!printer || !printer.data || !printer.data.heaters) return

        extruderModel.clear()
        heaterModel.clear()

        // Get all available heaters from printer data
        var heaters = printer.data.heaters.available_heaters || []

        for (var i = 0; i < heaters.length; i++) {
            var heaterName = heaters[i]

            if (heaterName.startsWith("extruder")) {
                extruderModel.append({
                    name: heaterName,
                    label: "0°C / 0°C",
                    isActive: heaterName === "extruder"
                })
            } else if (heaterName.startsWith("heater_")) {
                var displayName = heaterName.replace("heater_", "").replace("_", " ")
                heaterModel.append({
                    name: heaterName,
                    label: "0°C / 0°C",
                    isActive: false
                })
            }
        }
    }

    function updateTemperatureButton(heaterName, current, target, power) {
        var label = Math.round(current) + "°C / " + Math.round(target) + "°C"

        // Update extruder buttons
        for (var i = 0; i < extruderModel.count; i++) {
            if (extruderModel.get(i).name === heaterName) {
                extruderModel.setProperty(i, "label", label)
                return
            }
        }

        // Update heater buttons
        for (var j = 0; j < heaterModel.count; j++) {
            if (heaterModel.get(j).name === heaterName) {
                heaterModel.setProperty(j, "label", label)
                return
            }
        }
    }

    function navigateToTemperature(heaterName) {
        console.log("Navigate to temperature control for:", heaterName)
        // TODO: Navigate to temperature page
    }

    function updatePrintState(state) {
        console.log("Print state changed to:", state)

        // Map Klipper states to our internal states
        if (state === "printing") {
            currentState = "printing"
        } else if (state === "paused") {
            currentState = "paused"
        } else if (state === "complete") {
            currentState = "complete"
            circularProgress.progress = 1.0
        } else if (state === "cancelled") {
            currentState = "cancelled"
        } else if (state === "error") {
            currentState = "error"
        } else if (state === "standby") {
            currentState = "standby"
        }
    }

    function updateTimeLeft() {
        if (currentProgress <= 0 || printDuration <= 0) {
            timeLeftLabel.text = "--:--:--"
            estTimeLabel.text = "--:--:--"
            return
        }

        // Simple file-based estimation
        var estimatedTotal = printDuration / currentProgress
        var timeLeft = estimatedTotal - printDuration

        if (timeLeft > 0) {
            timeLeftLabel.text = formatTime(timeLeft)
            estTimeLabel.text = formatTime(estimatedTotal)
        } else {
            timeLeftLabel.text = "--:--:--"
            estTimeLabel.text = "--:--:--"
        }
    }

    Component.onCompleted: {
        console.log("JobStatusPage loaded, printer:", printer)
        if (printer) {
            console.log("Printer connected:", printer.connected)
            console.log("Print progress:", printer.printProgress)
            console.log("Print state:", printer.printerState)
        }
        initTemperatureButtons()

        // 初始化显示当前状态
        if (printer) {
            currentProgress = printer.printProgress || 0
            circularProgress.progress = currentProgress
            console.log("Initial progress:", currentProgress)

            currentFilename = printer.printFilename || ""
            if (currentFilename) {
                filenameLabel.text = currentFilename
            }

            // 如果没有打印任务，显示测试数据
            if (!currentFilename || currentFilename === "") {
                console.log("No active print, showing test data")
                filenameLabel.text = "test_model.gcode"
                currentProgress = 0.45
                circularProgress.progress = currentProgress
                printDuration = 1234
                elapsedLabel.text = formatTime(printDuration)
                currentLayer = 45
                totalLayers = 100
                layerLabel.text = currentLayer + " / " + totalLayers
                filamentUsedLabel.text = "15.5 m"
                extrudeFactorLabel.text = "100%"
                speedFactorLabel.text = "100%"
                fanSpeedLabel.text = "50%"
            }
        }
    }
}
