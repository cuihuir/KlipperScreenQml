// Job Status Page - Print Status Detail (Card-based Horizontal Layout)
// 打印状态详情页 - 卡片式横向布局
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
    // 性能优化：使用局部缓存减少QML属性绑定重计算
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

        // Temperature update - 只更新变化的值
        function onTemperatureUpdated(temps) {
            var data = (typeof temps === 'string') ? JSON.parse(temps) : temps
            if (data.extruder_temp !== undefined && Math.abs(data.extruder_temp - extruderTemp) >= 0.5) {
                extruderTemp = data.extruder_temp
            }
            if (data.extruder_target !== undefined && data.extruder_target !== extruderTarget) {
                extruderTarget = data.extruder_target
            }
            if (data.bed_temp !== undefined && Math.abs(data.bed_temp - bedTemp) >= 0.5) {
                bedTemp = data.bed_temp
            }
            if (data.bed_target !== undefined && data.bed_target !== bedTarget) {
                bedTarget = data.bed_target
            }
        }

        // Position update - 只更新变化的值
        function onPositionUpdated(pos) {
            var data = (typeof pos === 'string') ? JSON.parse(pos) : pos
            if (data.gcode_position && data.gcode_position.length >= 3) {
                var newZ = data.gcode_position[2] || 0
                if (Math.abs(newZ - zPosition) >= 0.05) {
                    zPosition = newZ
                }
            }
            if (data.homing_origin && data.homing_origin.length >= 3) {
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

    // ===== 主布局：横向卡片排列 =====
    RowLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingMedium

        // ===== 卡片 1: 缩略图 (300x300) =====
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: Style.bgCard
            radius: Style.radiusSmall
            border.width: Style.borderThin
            border.color: Style.border

            // 缩略图 - 纵向居中
            Rectangle {
                width: 300 - Style.spacingMedium * 2
                height: 300 - Style.spacingMedium * 2
                anchors.centerIn: parent
                color: Style.bgSecondary
                radius: Style.radiusSmall

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

                // 占位符：小船emoji
                Label {
                    anchors.centerIn: parent
                    text: "🚢"
                    font.pixelSize: 100
                    opacity: 0.3
                    visible: thumbnailImage.status !== Image.Ready
                }

                Label {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 70
                    text: "无缩略图"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    color: Style.textDisabled
                    visible: thumbnailImage.status !== Image.Ready
                }
            }
        }

        // ===== 卡片 2: 圆形进度 =====
        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: Style.bgCard
            radius: Style.radiusSmall
            border.width: Style.borderThin
            border.color: Style.border

            // 圆形进度条居中
            Components.CircularProgress {
                anchors.centerIn: parent
                width: 200
                height: 200
                progress: currentProgress
                progressColor: Style.accent
                backgroundColor: Style.bgSecondary
                lineWidth: 12
                progressText: Math.round(currentProgress * 100) + "%"
            }
        }

        // ===== 卡片 3: 打印信息（两列显示） =====
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.bgCard
            radius: Style.radiusSmall
            border.width: Style.borderThin
            border.color: Style.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingLarge
                spacing: Style.spacingMedium

                // 文件名
                Label {
                    Layout.fillWidth: true
                    text: currentFilename || "未选择文件"
                    font.pixelSize: Style.fontLarge
                    font.bold: true
                    font.family: Style.fontFamily
                    color: Style.accent
                    elide: Text.ElideMiddle
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: Style.borderThin
                    color: Style.divider
                }

                // 打印信息 - 两列显示
                GridLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    columns: 4
                    rowSpacing: Style.spacingLarge
                    columnSpacing: Style.spacingLarge

                    // 第一列
                    Label {
                        text: "已用时间"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        id: elapsedLabel
                        text: formatTime(printDuration)
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 第二列
                    Label {
                        text: "当前层"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: currentLayer + " / " + totalLayers
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 第一列
                    Label {
                        text: "剩余时间"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        id: timeLeftLabel
                        text: "--:--:--"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 第二列
                    Label {
                        text: "已用耗材"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: (filamentUsed / 1000).toFixed(1) + " m"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 第一列
                    Label {
                        text: "Z 位置"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: zPosition.toFixed(2) + " mm"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 第二列
                    Label {
                        text: "速度倍率"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: Math.round(speedFactor * 100) + "%"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 第一列
                    Label {
                        text: "挤出倍率"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: Math.round(extrudeFactor * 100) + "%"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }

                    // 第二列
                    Label {
                        text: "风扇"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }
                    Label {
                        text: Math.round(fanSpeed * 100) + "%"
                        font.pixelSize: Style.fontMedium
                        font.bold: true
                        font.family: Style.fontFamilyMono
                        color: Style.textPrimary
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // ===== 卡片 4: 温度控制（纵向排列按钮，内容横向） =====
        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: Style.bgCard
            radius: Style.radiusSmall
            border.width: Style.borderThin
            border.color: Style.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingLarge
                spacing: Style.spacingLarge

                // 热端温度
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgSecondary
                    radius: Style.radiusSmall
                    border.width: Style.borderMedium
                    border.color: Style.border

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: showTempKeypad("extruder")
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Style.spacingLarge

                        Components.ThemedIcon {
                            iconName: "heat-up"
                            iconSize: Style.iconSizeXLarge
                        }

                        ColumnLayout {
                            spacing: Style.spacingSmall

                            Label {
                                text: Math.round(extruderTemp) + "°C"
                                font.pixelSize: Style.fontXXLarge
                                font.bold: true
                                font.family: Style.fontFamilyMono
                                color: Style.getTempColor(extruderTemp, extruderTarget)
                            }

                            Label {
                                text: "→ " + Math.round(extruderTarget) + "°C"
                                font.pixelSize: Style.fontLarge
                                font.family: Style.fontFamilyMono
                                color: Style.textSecondary
                                visible: extruderTarget > 0
                            }
                        }
                    }
                }

                // 热床温度
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.bgSecondary
                    radius: Style.radiusSmall
                    border.width: Style.borderMedium
                    border.color: Style.border

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: showTempKeypad("bed")
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Style.spacingLarge

                        Components.ThemedIcon {
                            iconName: "bed"
                            iconSize: Style.iconSizeXLarge
                        }

                        ColumnLayout {
                            spacing: Style.spacingSmall

                            Label {
                                text: Math.round(bedTemp) + "°C"
                                font.pixelSize: Style.fontXXLarge
                                font.bold: true
                                font.family: Style.fontFamilyMono
                                color: Style.getTempColor(bedTemp, bedTarget)
                            }

                            Label {
                                text: "→ " + Math.round(bedTarget) + "°C"
                                font.pixelSize: Style.fontLarge
                                font.family: Style.fontFamilyMono
                                color: Style.textSecondary
                                visible: bedTarget > 0
                            }
                        }
                    }
                }
            }
        }

        // ===== 卡片 5: 操作按钮（纵向排列，填满高度） =====
        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: Style.bgCard
            radius: Style.radiusSmall
            border.width: Style.borderThin
            border.color: Style.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingLarge
                spacing: Style.spacingLarge

                // 暂停按钮
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Style.warning
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
                        spacing: Style.spacingMedium

                        Components.ThemedIcon {
                            iconName: "pause"
                            iconSize: Style.iconSizeLarge
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "暂停"
                            font.pixelSize: Style.fontXLarge
                            font.bold: true
                            font.family: Style.fontFamily
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // 继续按钮
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                        spacing: Style.spacingMedium

                        Components.ThemedIcon {
                            iconName: "resume"
                            iconSize: Style.iconSizeLarge
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "继续"
                            font.pixelSize: Style.fontXLarge
                            font.bold: true
                            font.family: Style.fontFamily
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // 取消按钮
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                        spacing: Style.spacingMedium

                        Components.ThemedIcon {
                            iconName: "cancel"
                            iconSize: Style.iconSizeLarge
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "取消"
                            font.pixelSize: Style.fontXLarge
                            font.bold: true
                            font.family: Style.fontFamily
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // 微调按钮
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                        spacing: Style.spacingMedium

                        Components.ThemedIcon {
                            iconName: "fine-tune"
                            iconSize: Style.iconSizeLarge
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: "微调"
                            font.pixelSize: Style.fontXLarge
                            font.bold: true
                            font.family: Style.fontFamily
                            color: Style.bgPrimary
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
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
        console.log("JobStatusPage loaded (card-based layout with circular progress)")
        if (printer) {
            currentProgress = printer.printProgress || 0
            currentFilename = printer.printFilename || ""
            thumbnailUrl = printer.printThumbnail || ""
        }
    }

    // Bind thumbnailUrl to printer.printThumbnail
    Connections {
        target: printer
        function onPrintStatsUpdated(stats) {
            if (printer) {
                thumbnailUrl = printer.printThumbnail || ""
            }
        }
    }
}
