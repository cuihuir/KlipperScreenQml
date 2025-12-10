import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * TempWidget - 温度显示 Widget
 *
 * 显示单个加热器的当前温度和目标温度。
 * 点击弹出键盘编辑目标温度。
 *
 * 使用示例:
 *   TempWidget {
 *       widgetId: "temp_hotend"
 *       heaterName: "热端"
 *       heaterType: "extruder"  // "extruder" or "bed"
 *   }
 */
HomeWidget {
    id: root

    // ===== 公共属性 =====

    /**
     * 加热器名称（如 "热端", "热床"）
     */
    property string heaterName: "温度"

    /**
     * 加热器类型（"extruder" 或 "bed"）
     */
    property string heaterType: "extruder"

    /**
     * 当前温度（°C） - 内部属性，由数据绑定更新
     */
    property real currentTemp: 0.0

    /**
     * 目标温度（°C） - 内部属性，由数据绑定更新
     */
    property real targetTemp: 0.0

    // 平滑动画：温度变化
    Behavior on currentTemp {
        SmoothedAnimation {
            duration: Style.durationNormal
            velocity: -1  // 使用 duration 而不是 velocity
        }
    }

    Behavior on targetTemp {
        SmoothedAnimation {
            duration: Style.durationFast
            velocity: -1
        }
    }

    // ===== 基类属性配置 =====
    title: heaterName
    widgetState: "idle"
    isInteractive: true

    // ===== 数据绑定：连接 MoonrakerClient =====
    Connections {
        target: app ? app.printer : null

        function onTemperatureUpdated(temps) {
            if (root.heaterType === "extruder") {
                root.currentTemp = temps.extruder_temp || 0.0
                root.targetTemp = temps.extruder_target || 0.0
            } else if (root.heaterType === "bed") {
                root.currentTemp = temps.bed_temp || 0.0
                root.targetTemp = temps.bed_target || 0.0
            }
        }
    }

    // ===== 内容区域 =====
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingSmall

        // 当前温度（超大数字）
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.spacingXSmall

            Text {
                text: root.currentTemp.toFixed(1)
                font.pixelSize: Style.fontXXLarge
                font.family: Style.fontFamilyMono
                font.bold: true
                color: Style.getTempColor(root.currentTemp, root.targetTemp)
            }

            Text {
                text: "°C"
                font.pixelSize: Style.fontLarge
                font.family: Style.fontFamily
                color: Style.textSecondary
                Layout.alignment: Qt.AlignBaseline
            }
        }

        // 目标温度（小字）
        Text {
            visible: root.targetTemp > 0
            text: "目标: " + root.targetTemp.toFixed(0) + "°C"
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }

        // 占位符提示
        Text {
            visible: root.currentTemp === 0 && root.targetTemp === 0
            text: "等待数据..."
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textDisabled
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ===== 点击事件：显示温度编辑键盘 =====
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            tempKeypadPopup.open()
        }
    }

    // ===== 温度编辑键盘弹出层 =====
    Popup {
        id: tempKeypadPopup
        modal: true   // 模态弹窗，阻止底层点击
        dim: true     // 显示半透明背景
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // 居中显示
        anchors.centerIn: Overlay.overlay
        width: Style.windowWidth * 0.6  // 占据屏幕宽度的 60%
        height: Style.baseUnit * 40  // 增大高度以容纳更大的按键

        // 处理键盘可见性变化
        onVisibleChanged: {
            // 键盘隐藏时无需处理，导航可以正常进行
            // 如果将来需要在导航时自动关闭键盘，可以监听导航事件
        }

        // 转场动画
        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: Style.durationFast
                easing.type: Easing.OutQuad
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: Style.durationFast
                easing.type: Easing.InQuad
            }
        }

        // 键盘组件
        NumericKeypad {
            anchors.fill: parent
            title: "SET " + root.heaterName.toUpperCase() + " TEMP"
            maxLength: 3
            inputValue: root.targetTemp > 0 ? Math.round(root.targetTemp).toString() : ""

            onConfirmed: (value) => {
                var temp = parseInt(value)
                if (temp >= 0 && temp <= 300) {
                    // 调用后端方法设置温度
                    if (app && app.printer) {
                        if (root.heaterType === "extruder") {
                            app.printer.setExtruderTemp("extruder", temp)
                        } else if (root.heaterType === "bed") {
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
}
