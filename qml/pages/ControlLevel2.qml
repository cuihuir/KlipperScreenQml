import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components"

/**
 * ControlLevel2 - 控制页面 Level 2
 * 测试导航深度 3
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
            text: "轴控制 (Level 2)"
            font.pixelSize: Style.fontXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        Text {
            text: "这是二级子页面。点击 < 按钮应该返回到 Level 1 (控制页面)。"
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
                    color: Style.info
                }

                Text {
                    text: "(应该是 3)"
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
                text: "进入 Level 3\n(X轴控制)"
                buttonColor: Style.success

                onClicked: {
                    console.log("Navigate to ControlLevel3")
                    if (root.stackView) {
                        root.stackView.push("ControlLevel3.qml")
                        if (navigationManager) {
                            navigationManager.pushPage("control-level3")
                        }
                    }
                }
            }

            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Y轴控制\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    console.log("Y轴控制")
                }
            }

            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Z轴控制\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    console.log("Z轴控制")
                }
            }

            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "归零\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    console.log("归零")
                }
            }
        }
    }

    StackView.onActivated: {
        console.log("ControlLevel2 activated, depth:", stackView ? stackView.depth : "-")
    }

    StackView.onDeactivated: {
        console.log("ControlLevel2 deactivated")
    }

    Component.onCompleted: {
        console.log("ControlLevel2 created")
    }
}
