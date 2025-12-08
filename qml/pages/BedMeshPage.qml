import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// 网格调平页面
Page {
    id: root
    property var printer: null

    background: Rectangle {
        color: Style.bgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        Label {
            text: "床网格调平"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 操作按钮行
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingLarge

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeightLarge
                color: Style.accent
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "开始校准"
                    font.pixelSize: Style.fontLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: startMeshCalibration()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeightLarge
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "保存配置"
                    font.pixelSize: Style.fontLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: saveMeshConfig()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeightLarge
                color: Style.warning
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "清除网格"
                    font.pixelSize: Style.fontLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: clearMesh()
                }
            }
        }

        // 网格可视化区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingMedium
                spacing: Style.spacingMedium

                Label {
                    text: "床网格可视化"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.textPrimary
                }

                // 网格绘制区域 (简化版 - 7x7 网格示例)
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 2

                    Repeater {
                        model: 49  // 7x7 网格

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumWidth: Style.baseUnit * 4
                            Layout.minimumHeight: Style.baseUnit * 4
                            color: getMeshColor(index)
                            border.width: 1
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: getMeshValue(index).toFixed(3)
                                font.pixelSize: Style.fontXSmall
                                font.family: Style.fontFamilyMono
                                color: Style.textPrimary
                            }
                        }
                    }
                }

                // 图例
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingLarge

                    Rectangle {
                        width: Style.baseUnit * 2
                        height: Style.baseUnit * 2
                        color: Style.error
                    }
                    Label {
                        text: "低"
                        font.pixelSize: Style.fontSmall
                        color: Style.textSecondary
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: Style.baseUnit * 2
                        height: Style.baseUnit * 2
                        color: Style.warning
                    }
                    Label {
                        text: "中"
                        font.pixelSize: Style.fontSmall
                        color: Style.textSecondary
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: Style.baseUnit * 2
                        height: Style.baseUnit * 2
                        color: Style.success
                    }
                    Label {
                        text: "高"
                        font.pixelSize: Style.fontSmall
                        color: Style.textSecondary
                    }
                }
            }
        }

        // 状态信息
        Label {
            Layout.fillWidth: true
            text: "注意: 网格数据仅在校准后可用"
            font.pixelSize: Style.fontSmall
            color: Style.textSecondary
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // 模拟网格数据 (实际应从 printer.bedMesh 获取)
    property var meshData: []

    function getMeshValue(index) {
        // 如果有真实数据,从 meshData 获取
        if (meshData.length > index) {
            return meshData[index]
        }
        // 模拟数据: 中心高,边缘低
        var row = Math.floor(index / 7)
        var col = index % 7
        var centerDist = Math.sqrt(Math.pow(row - 3, 2) + Math.pow(col - 3, 2))
        return (4.5 - centerDist) * 0.05  // -0.15 到 0.15 范围
    }

    function getMeshColor(index) {
        var value = getMeshValue(index)
        // 颜色映射: 低=红色, 中=黄色, 高=绿色
        if (value < -0.05) return Style.error
        if (value > 0.05) return Style.success
        return Style.warning
    }

    function startMeshCalibration() {
        if (!printer) return
        printer.sendGcode("G28")  // 先归零
        printer.sendGcode("BED_MESH_CALIBRATE")  // 开始网格校准
        console.log("Bed mesh calibration started")
    }

    function saveMeshConfig() {
        if (!printer) return
        printer.sendGcode("SAVE_CONFIG")
        console.log("Mesh configuration saved")
    }

    function clearMesh() {
        if (!printer) return
        printer.sendGcode("BED_MESH_CLEAR")
        meshData = []
        console.log("Mesh cleared")
    }
}
