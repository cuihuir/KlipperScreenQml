import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * TempWidget - 温度显示 Widget
 *
 * 显示单个加热器的当前温度和目标温度。
 * 当前为占位符实现，显示静态数据。
 *
 * 使用示例:
 *   TempWidget {
 *       widgetId: "temp_hotend"
 *       heaterName: "热端"
 *       currentTemp: 25.0
 *       targetTemp: 200.0
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
     * 当前温度（°C）
     */
    property real currentTemp: 0.0

    /**
     * 目标温度（°C）
     */
    property real targetTemp: 0.0

    // ===== 基类属性配置 =====
    title: heaterName
    widgetState: "idle"
    isInteractive: true

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
                anchors.baseline: parent.children[0].baseline
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

    // ===== 点击事件（未来实现温度编辑） =====
    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("TempWidget clicked:", root.heaterName, "current:", root.currentTemp, "target:", root.targetTemp)
            // TODO: Phase 4 - 打开温度编辑对话框
        }
    }
}
