import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components"

/**
 * ControlLevel4 - 控制页面 Level 4
 * 测试导航深度 5 (最深层)
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
            text: "精确移动 (Level 4)"
            font.pixelSize: Style.fontXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
        }

        Text {
            text: "这是四级子页面（最深层）。点击 < 按钮应该返回到 Level 3 (X轴控制)。\n点击 HOME 🏠 按钮应该直接返回主页。"
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // 导航深度显示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Style.bgCard
            border.width: Style.borderMedium
            border.color: Style.warning
            radius: Style.radiusSmall

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.spacingSmall

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Style.spacingMedium

                    Text {
                        text: "当前导航深度:"
                        font.pixelSize: Style.fontMedium
                        font.family: Style.fontFamily
                        color: Style.textSecondary
                    }

                    Text {
                        text: navigationManager ? navigationManager.currentDepth : "-"
                        font.pixelSize: Style.fontXXLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.warning
                    }

                    Text {
                        text: "(应该是 5)"
                        font.pixelSize: Style.fontSmall
                        font.family: Style.fontFamily
                        color: Style.textDisabled
                    }
                }

                Text {
                    text: "🎉 这是最深层！"
                    font.pixelSize: Style.fontLarge
                    font.family: Style.fontFamily
                    color: Style.accent
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // 测试说明
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: Qt.rgba(Style.info.r, Style.info.g, Style.info.b, 0.1)
            border.width: Style.borderThin
            border.color: Style.info
            radius: Style.radiusSmall

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingMedium
                spacing: Style.spacingSmall

                Text {
                    text: "测试说明："
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.info
                }

                Text {
                    text: "• 点击 < 返回：应该逐级返回 (4→3→2→1→主页)\n• 点击 🏠 HOME：应该直接跳转到主页\n• 导航深度应该实时更新"
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    color: Style.textPrimary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        // 精确移动按钮
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: Style.spacingSmall
            columnSpacing: Style.spacingSmall

            Repeater {
                model: ["0.1mm", "0.5mm", "1mm", "5mm", "10mm", "50mm"]

                MetroButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "X+ " + modelData
                    buttonColor: Style.bgCard

                    onClicked: {
                        console.log("X+ " + modelData)
                    }
                }
            }
        }
    }

    StackView.onActivated: {
        console.log("ControlLevel4 activated, depth:", stackView ? stackView.depth : "-")
    }

    StackView.onDeactivated: {
        console.log("ControlLevel4 deactivated")
    }

    Component.onCompleted: {
        console.log("ControlLevel4 created")
    }
}
