import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components"

/**
 * ControlPage - 控制页面
 *
 * 测试多级导航的页面，包含 3-4 级子页面导航测试
 */
Page {
    id: root

    // Properties
    property var printer: null
    property StackView stackView: StackView.view

    // Signals
    signal placeholderRequested(string featureName)

    // 页面背景
    background: Rectangle {
        color: Style.bgPrimary
    }

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // 标题
        Text {
            text: "控制页面 (Level 1)"
            font.pixelSize: Style.fontXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        // 说明文本
        Text {
            text: "这是一级子页面。点击下面的按钮可以进入更深层的页面测试导航。"
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
                    color: Style.accent
                }

                Text {
                    text: "当前页面: " + (navigationManager ? navigationManager.currentPage : "-")
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    color: Style.textSecondary
                }
            }
        }

        // 测试按钮区域
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: Style.spacingMedium
            columnSpacing: Style.spacingMedium

            // 进入 Level 2
            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "进入 Level 2\n(轴控制)"
                buttonColor: Style.info

                onClicked: {
                    console.log("Navigate to ControlLevel2")
                    if (root.stackView) {
                        root.stackView.push("ControlLevel2.qml")
                        if (navigationManager) {
                            navigationManager.pushPage("control-level2")
                        }
                    }
                }
            }

            // 温度控制（占位符）
            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "温度控制\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    root.placeholderRequested("温度控制")
                }
            }

            // 挤出控制（占位符）
            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "挤出控制\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    root.placeholderRequested("挤出控制")
                }
            }

            // 风扇控制（占位符）
            MetroButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "风扇控制\n(占位符)"
                buttonColor: Style.bgCard

                onClicked: {
                    root.placeholderRequested("风扇控制")
                }
            }
        }
    }

    // ===== 生命周期钩子 =====
    StackView.onActivated: {
        console.log("ControlPage (Level 1) activated, stackView:", stackView, "depth:", stackView ? stackView.depth : "-")
    }

    StackView.onDeactivated: {
        console.log("ControlPage (Level 1) deactivated")
    }

    Component.onCompleted: {
        console.log("ControlPage (Level 1) created")
    }
}
