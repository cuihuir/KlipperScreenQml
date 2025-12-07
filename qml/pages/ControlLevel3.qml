import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components"

/**
 * ControlLevel3 - 控制页面 Level 3
 * 测试导航深度 4
 */
Page {
    id: root

    property StackView stackView: StackView.view

    background: Rectangle {
        color: Style.bgPrimary
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        Text {
            text: "X轴控制 (Level 3)"
            font.pixelSize: Style.fontXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        Text {
            text: "这是三级子页面。点击 < 按钮应该返回到 Level 2 (轴控制)。"
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // 导航深度显示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Style.bgCard
            border.width: Style.borderThin
            border.color: Style.border
            radius: Style.radiusSmall

            RowLayout {
                anchors.centerIn: parent
                spacing: Style.spacingMedium

                Text {
                    text: "当前导航深度:"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    color: Style.textSecondary
                }

                Text {
                    text: navigationManager ? navigationManager.currentDepth : "-"
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.success
                }

                Text {
                    text: "(应该是 4)"
                    font.pixelSize: Style.fontSmall
                    font.family: Style.fontFamily
                    color: Style.textDisabled
                }
            }
        }

        // 测试按钮
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: Style.spacingMedium
            columnSpacing: Style.spacingMedium

            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "进入 Level 4\n(精确移动)"
                buttonColor: Style.warning

                onClicked: {
                    console.log("Navigate to ControlLevel4")
                    if (root.stackView) {
                        root.stackView.push(Qt.resolvedUrl("ControlLevel4.qml"))
                        if (navigationManager) {
                            navigationManager.pushPage("control-level4")
                        }
                    }
                }
            }

            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "X+ 10mm\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    console.log("X+ 10mm")
                }
            }

            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "X- 10mm\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    console.log("X- 10mm")
                }
            }

            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "X归零\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    console.log("X归零")
                }
            }
        }
    }

    StackView.onActivated: {
        console.log("ControlLevel3 activated, depth:", stackView ? stackView.depth : "-")
    }

    StackView.onDeactivated: {
        console.log("ControlLevel3 deactivated")
    }

    Component.onCompleted: {
        console.log("ControlLevel3 created")
    }
}
