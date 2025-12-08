// Job Status Page - Print Status Detail (Optimized Layout)
// 打印状态详情页 - 优化纵向布局
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

Page {
    id: root

    property var printer: null
    property string currentState: "standby"  // printing, paused, complete, cancelled, error, standby
    property string currentFilename: ""
    property real currentProgress: 0.0
    property string thumbnailUrl: ""

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

    // Temperature data
    property real extruderTemp: 0.0
    property real extruderTarget: 0.0
    property real bedTemp: 0.0
    property real bedTarget: 0.0

    background: Rectangle {
        color: Style.bgPrimary
    }

    // Connections to MoonrakerClient signals
    Connections {
        target: printer

        // Print stats update
        function onPrintStatsUpdated(stats) {
            var data = (typeof stats === 'string') ? JSON.parse(stats) : stats
            if (data.state) {
                updatePrintState(data.state)
            }
            if (data.filename) {
                currentFilename = data.filename
            }
            if (data.print_duration !== undefined) {
                printDuration = data.print_duration
            }
            if (data.filament_used !== undefined) {
                filamentUsed = data.filament_used
            }
            if (data.info) {
                if (data.info.current_layer !== undefined) currentLayer = data.info.current_layer
                if (data.info.total_layer !== undefined) totalLayers = data.info.total_layer
            }
        }

        // Print progress update
        function onPrintProgressChanged(progress) {
            var data = (typeof progress === 'string') ? JSON.parse(progress) : progress
            if (data.progress !== undefined) {
                currentProgress = data.progress
            }
        }

        // Temperature update
        function onTemperatureUpdated(temps) {
            var data = (typeof temps === 'string') ? JSON.parse(temps) : temps
            if (data.extruder_temp !== undefined) extruderTemp = data.extruder_temp
            if (data.extruder_target !== undefined) extruderTarget = data.extruder_target
            if (data.bed_temp !== undefined) bedTemp = data.bed_temp
            if (data.bed_target !== undefined) bedTarget = data.bed_target
        }

        // Position update
        function onPositionUpdated(pos) {
            var data = (typeof pos === 'string') ? JSON.parse(pos) : pos
            if (data.gcode_position) {
                zPosition = data.gcode_position[2] || 0
            }
            if (data.homing_origin) {
                zOffset = data.homing_origin[2] || 0
            }
            if (data.extrude_factor !== undefined) {
                extrudeFactor = data.extrude_factor
            }
            if (data.speed_factor !== undefined) {
                speedFactor = data.speed_factor
            }
            if (data.speed !== undefined) {
                requestedSpeed = data.speed / 60 * speedFactor
            }
        }

        // Fan state change
        function onFanStateChanged(fanName, isOn, speed) {
            if (fanName === "fan") {
                fanSpeed = speed
            }
        }

        // Printer state change
        function onPrinterStateChanged(state) {
            updatePrintState(state)
        }
    }

    // Time left calculation timer
    Timer {
        id: timeLeftTimer
        interval: 1000
        running: currentState === "printing" || currentState === "paused"
        repeat: true
        onTriggered: updateTimeLeft()
    }

    // ===== 主布局：横向排列 =====
    RowLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // ===== 左侧：缩略图 + 信息（纵向） =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Style.spacingMedium

            // 缩略图区域 (300x300)
            Rectangle {
                Layout.preferredWidth: 300
                Layout.preferredHeight: 300
                Layout.alignment: Qt.AlignHCenter
                color: Style.bgCard
                radius: Style.radiusSmall
                border.width: Style.borderThin
                border.color: Style.border

                Image {
                    id: thumbnailImage
                    anchors.fill: parent
                    anchors.margins: Style.spacingSmall
                    fillMode: Image.PreserveAspectFit
                    source: thumbnailUrl || ""
                    visible: status === Image.Ready

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: showFullscreenThumbnail()
                    }
                }

                // 占位符：使用文本代替（小船emoji）
                Label {
                    anchors.centerIn: parent
                    text: "🚢"
                    font.pixelSize: 120
                    opacity: 0.3
                    visible: thumbnailImage.status !== Image.Ready
                }

                Label {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 80
                    text: "无缩略图"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    color: Style.textDisabled
                    visible: thumbnailImage.status !== Image.Ready
                }
            }

            // 文件名
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.bgCard
                radius: Style.radiusSmall
                border.width: Style.borderThin
                border.color: Style.border

                Label {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    text: currentFilename || "未选择文件"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    font.family: Style.fontFamily
                    color: Style.accent
                    elide: Text.ElideMiddle
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // 进度条
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: Style.bgCard
                radius: Style.radiusSmall
                border.width: Style.borderThin
                border.color: Style.border

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "进度"
                            font.pixelSize: Style.fontNormal
                            font.family: Style.fontFamily
                            color: Style.textSecondary
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: Math.round(currentProgress * 100) + "%"
                            font.pixelSize: Style.fontLarge
                            font.bold: true
                            font.family: Style.fontFamilyMono
                            color: Style.accent
                        }
                    }

                    ProgressBar {
                        Layout.fillWidth: true
                        from: 0
                        to: 1.0
                        value: currentProgress
                    }
                }
            }

            // 打印信息网格
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Style.bgCard
                radius: Style.radiusSmall
                border.width: Style.borderThin
                border.color: Style.border

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    columns: 2
                    rowSpacing: Style.spacingSmall
                    columnSpacing: Style.spacingMedium

                    // 已用时间
                    Label {
                        text: "已用时间"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        id: elapsedLabel
                        text: formatTime(printDuration)
                        font.pixelSize: Style.fontNormal
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 剩余时间
                    Label {
                        text: "剩余时间"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        id: timeLeftLabel
                        text: "--:--:--"
                        font.pixelSize: Style.fontNormal
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 当前层
                    Label {
                        text: "当前层"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: currentLayer + " / " + totalLayers
                        font.pixelSize: Style.fontNormal
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 耗材用量
                    Label {
                        text: "已用耗材"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: (filamentUsed / 1000).toFixed(1) + " m"
                        font.pixelSize: Style.fontNormal
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // Z 位置
                    Label {
                        text: "Z 位置"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: zPosition.toFixed(2) + " mm"
                        font.pixelSize: Style.fontNormal
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 速度倍率
                    Label {
                        text: "速度倍率"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: Math.round(speedFactor * 100) + "%"
                        font.pixelSize: Style.fontNormal
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 风扇速度
                    Label {
                        text: "风扇"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: Math.round(fanSpeed * 100) + "%"
                        font.pixelSize: Style.fontNormal
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }
                }
            }
        }

        // ===== 右侧：温度控制 + 操作按钮（纵向） =====
        ColumnLayout {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            spacing: Style.spacingMedium

            // 温度控制按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 8
                color: Style.bgCard
                radius: Style.radiusSmall
                border.width: Style.borderMedium
                border.color: Style.border

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: showTempKeypad("extruder")
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingXSmall

                    Components.ThemedIcon {
                        iconName: "heat-up"
                        iconSize: Style.iconSizeMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "热端"
                        font.pixelSize: Style.fontSmall
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: Math.round(extruderTemp) + "°C"
                        font.pixelSize: Style.fontXLarge
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.getTempColor(extruderTemp, extruderTarget)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "→ " + Math.round(extruderTarget) + "°C"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamilyMono
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                        visible: extruderTarget > 0
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 8
                color: Style.bgCard
                radius: Style.radiusSmall
                border.width: Style.borderMedium
                border.color: Style.border

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: showTempKeypad("bed")
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.spacingMedium
                    spacing: Style.spacingXSmall

                    Components.ThemedIcon {
                        iconName: "bed"
                        iconSize: Style.iconSizeMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "热床"
                        font.pixelSize: Style.fontSmall
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: Math.round(bedTemp) + "°C"
                        font.pixelSize: Style.fontXLarge
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.getTempColor(bedTemp, bedTarget)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "→ " + Math.round(bedTarget) + "°C"
                        font.pixelSize: Style.fontNormal
                        font.family: Style.fontFamilyMono
                        color: Style.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                        visible: bedTarget > 0
                    }
                }
            }

            // 间隔
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.spacingMedium
            }

            // 操作按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: currentState === "printing" ? Style.warning : Style.bgDisabled
                radius: Style.radiusSmall
                border.width: Style.borderMedium
                border.color: Style.border
                visible: currentState === "printing"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pausePrint()
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingXSmall

                    Components.ThemedIcon {
                        iconName: "pause"
                        iconSize: Style.iconSizeMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "暂停"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamily
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: Style.success
                radius: Style.radiusSmall
                border.width: Style.borderMedium
                border.color: Style.border
                visible: currentState === "paused"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: resumePrint()
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingXSmall

                    Components.ThemedIcon {
                        iconName: "resume"
                        iconSize: Style.iconSizeMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "继续"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamily
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: Style.error
                radius: Style.radiusSmall
                border.width: Style.borderMedium
                border.color: Style.border
                visible: currentState === "printing" || currentState === "paused"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: showCancelDialog()
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingXSmall

                    Components.ThemedIcon {
                        iconName: "cancel"
                        iconSize: Style.iconSizeMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "取消"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamily
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 6
                color: Style.info
                radius: Style.radiusSmall
                border.width: Style.borderMedium
                border.color: Style.border
                visible: currentState === "printing" || currentState === "paused"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navigateToFineTune()
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Style.spacingXSmall

                    Components.ThemedIcon {
                        iconName: "fine-tune"
                        iconSize: Style.iconSizeMedium
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "微调"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamily
                        color: Style.bgPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // 填充剩余空间
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    // ===== 温度键盘弹出层 =====
    Popup {
        id: tempKeypadPopup
        modal: true
        dim: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay
        width: Style.windowWidth * 0.6
        height: Style.baseUnit * 40

        property string heaterType: "extruder"

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: Style.durationFast
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.9
                to: 1.0
                duration: Style.durationFast
                easing.type: Easing.OutBack
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: Style.durationFast
                easing.type: Easing.InCubic
            }
        }

        Components.NumericKeypad {
            anchors.fill: parent
            title: "设置 " + (tempKeypadPopup.heaterType === "extruder" ? "热端" : "热床") + " 温度"
            maxLength: 3
            inputValue: {
                if (tempKeypadPopup.heaterType === "extruder") {
                    return extruderTarget > 0 ? Math.round(extruderTarget).toString() : ""
                } else {
                    return bedTarget > 0 ? Math.round(bedTarget).toString() : ""
                }
            }

            onConfirmed: (value) => {
                var temp = parseInt(value)
                if (temp >= 0 && temp <= 300) {
                    if (app && app.printer) {
                        if (tempKeypadPopup.heaterType === "extruder") {
                            app.printer.setExtruderTemp("extruder", temp)
                        } else {
                            app.printer.setBedTemp(temp)
                        }
                    }
                    tempKeypadPopup.close()
                }
            }

            onCancelled: {
                tempKeypadPopup.close()
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

    // ===== Functions =====
    function pausePrint() {
        if (!printer) return
        console.log("暂停打印")
        printer.pausePrint()
    }

    function resumePrint() {
        if (!printer) return
        console.log("继续打印")
        printer.resumePrint()
    }

    function cancelPrint() {
        if (!printer) return
        console.log("取消打印")
        currentState = "cancelling"
        printer.cancelPrint()
    }

    function showCancelDialog() {
        cancelDialog.open()
    }

    function showTempKeypad(heaterType) {
        tempKeypadPopup.heaterType = heaterType
        tempKeypadPopup.open()
    }

    function navigateToFineTune() {
        var appWindow = root.Window.window
        if (appWindow && appWindow.pageRegistry) {
            appWindow.pageRegistry.navigateTo("fine_tune")
        }
    }

    function showFullscreenThumbnail() {
        console.log("Show fullscreen thumbnail")
        // TODO: Implement fullscreen thumbnail dialog
    }

    function formatTime(seconds) {
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        var s = Math.floor(seconds % 60)
        return (h < 10 ? "0" + h : h) + ":" +
               (m < 10 ? "0" + m : m) + ":" +
               (s < 10 ? "0" + s : s)
    }

    function updatePrintState(state) {
        console.log("Print state changed to:", state)

        if (state === "printing") {
            currentState = "printing"
        } else if (state === "paused") {
            currentState = "paused"
        } else if (state === "complete") {
            currentState = "complete"
            currentProgress = 1.0
        } else if (state === "cancelled") {
            currentState = "cancelled"
        } else if (state === "error") {
            currentState = "error"
        } else if (state === "standby" || state === "ready") {
            currentState = "standby"
        }
    }

    function updateTimeLeft() {
        if (currentProgress <= 0 || printDuration <= 0) {
            timeLeftLabel.text = "--:--:--"
            return
        }

        var estimatedTotal = printDuration / currentProgress
        var timeLeft = estimatedTotal - printDuration

        if (timeLeft > 0) {
            timeLeftLabel.text = formatTime(timeLeft)
        } else {
            timeLeftLabel.text = "--:--:--"
        }
    }

    Component.onCompleted: {
        console.log("JobStatusPage loaded (optimized layout)")
        if (printer) {
            currentProgress = printer.printProgress || 0
            currentFilename = printer.printFilename || ""

            // TODO: Load thumbnail from metadata
            // thumbnailUrl = "..."
        }
    }
}
