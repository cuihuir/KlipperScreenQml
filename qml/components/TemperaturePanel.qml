import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Metro风格温度面板
Item {
    id: root

    property var printer: null

    signal temperatureEditRequested(string title, var callback)

    // 阻止点击穿透到底层
    MouseArea {
        anchors.fill: parent
        onPressed: mouse.accepted = false  // 让子组件响应点击
        preventStealing: true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Style.spacingMedium

        // 挤出机温度
        TempControl {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "EXTRUDER"
            currentTemp: printer ? printer.extruderTemp : 0
            targetTemp: printer ? printer.extruderTarget : 0
            maxTemp: 300
            quickTemp: 200
            onSetTemperature: function(temp) {
                if (printer) {
                    printer.setExtruderTemp("extruder", temp)
                }
            }
            onEditTemperature: {
                root.temperatureEditRequested("EXTRUDER TEMPERATURE", function(temp) {
                    if (printer) {
                        printer.setExtruderTemp("extruder", temp)
                    }
                })
            }
        }

        // 热床温度
        TempControl {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "HEATED BED"
            currentTemp: printer ? printer.bedTemp : 0
            targetTemp: printer ? printer.bedTarget : 0
            maxTemp: 120
            quickTemp: 60
            onSetTemperature: function(temp) {
                if (printer) {
                    printer.setBedTemp(temp)
                }
            }
            onEditTemperature: {
                root.temperatureEditRequested("BED TEMPERATURE", function(temp) {
                    if (printer) {
                        printer.setBedTemp(temp)
                    }
                })
            }
        }
    }
}
