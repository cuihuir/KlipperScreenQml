import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components" as Components

// Input Shaper (振动补偿) 页面
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
            text: "振动补偿 (Input Shaper)"
            font.pixelSize: Style.fontXXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 当前配置显示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 12
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.divider

            GridLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingMedium
                columns: 2
                rowSpacing: Style.spacingMedium
                columnSpacing: Style.spacingLarge

                Label {
                    text: "X 轴类型:"
                    font.pixelSize: Style.fontMedium
                    color: Style.textSecondary
                }
                Label {
                    text: shaperTypeX
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.accent
                }

                Label {
                    text: "X 轴频率:"
                    font.pixelSize: Style.fontMedium
                    color: Style.textSecondary
                }
                Label {
                    text: shaperFreqX.toFixed(1) + " Hz"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.accent
                }

                Label {
                    text: "Y 轴类型:"
                    font.pixelSize: Style.fontMedium
                    color: Style.textSecondary
                }
                Label {
                    text: shaperTypeY
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.info
                }

                Label {
                    text: "Y 轴频率:"
                    font.pixelSize: Style.fontMedium
                    color: Style.textSecondary
                }
                Label {
                    text: shaperFreqY.toFixed(1) + " Hz"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.info
                }
            }
        }

        // 测试和校准按钮
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Style.spacingMedium
            columnSpacing: Style.spacingLarge

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeightLarge
                color: Style.accent
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "测试 X 轴"
                    font.pixelSize: Style.fontLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: testAxis("X")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.buttonHeightLarge
                color: Style.info
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "测试 Y 轴"
                    font.pixelSize: Style.fontLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: testAxis("Y")
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
                    text: "自动校准"
                    font.pixelSize: Style.fontLarge
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: autoCalibrate()
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
                    onClicked: saveConfig()
                }
            }
        }

        // Shaper 类型选择
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
                    text: "Shaper 类型选择"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.textPrimary
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 5
                    rowSpacing: Style.spacingSmall
                    columnSpacing: Style.spacingSmall

                    Repeater {
                        model: ["ZV", "MZV", "EI", "2HUMP_EI", "3HUMP_EI"]

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: Style.baseUnit * 5
                            color: shaperTypeX === modelData ? Style.accent : Style.bgSecondary
                            border.width: Style.borderThin
                            border.color: Style.divider

                            Label {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: Style.fontSmall
                                font.bold: true
                                color: shaperTypeX === modelData ? Style.bgPrimary : Style.textPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: setShaperType(modelData)
                            }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: "提示: ZV 最快但精度低, 3HUMP_EI 最精确但速度慢"
                    font.pixelSize: Style.fontXSmall
                    color: Style.textSecondary
                    wrapMode: Text.WordWrap
                }
            }
        }

        // 说明文字
        Label {
            Layout.fillWidth: true
            text: "注意: 需要加速度计硬件支持。测试前确保打印机已归零。"
            font.pixelSize: Style.fontSmall
            color: Style.textSecondary
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    // 配置属性 (实际应从 printer 对象获取)
    property string shaperTypeX: "MZV"
    property string shaperTypeY: "MZV"
    property real shaperFreqX: 54.5
    property real shaperFreqY: 48.2

    function testAxis(axis) {
        if (!printer) return
        var gcode = "SHAPER_CALIBRATE AXIS=" + axis
        printer.sendGcode(gcode)
        console.log("Testing axis:", axis)
    }

    function autoCalibrate() {
        if (!printer) return
        printer.sendGcode("G28")  // 先归零
        printer.sendGcode("SHAPER_CALIBRATE")
        console.log("Auto calibration started")
    }

    function setShaperType(type) {
        shaperTypeX = type
        shaperTypeY = type
        console.log("Shaper type set to:", type)
    }

    function saveConfig() {
        if (!printer) return
        printer.sendGcode("SAVE_CONFIG")
        console.log("Input shaper configuration saved")
    }
}
