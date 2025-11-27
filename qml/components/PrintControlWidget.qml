import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * PrintControlWidget - 打印控制 Widget
 *
 * 显示打印状态和提供打印控制按钮。
 * 当前为占位符实现，仅显示"开始打印"按钮（idle 状态）。
 *
 * 状态机:
 * - idle: 空闲状态，显示"开始打印"按钮
 * - printing: 打印中，显示暂停/取消按钮和进度
 * - paused: 暂停状态，显示恢复/取消按钮
 * - complete: 打印完成，显示"完成"提示
 *
 * 使用示例:
 *   PrintControlWidget {
 *       widgetId: "print_control"
 *       printState: "idle"
 *       progress: 0.0
 *   }
 */
HomeWidget {
    id: root

    // ===== 公共属性 =====

    /**
     * 打印状态
     * @values "idle" | "printing" | "paused" | "complete"
     */
    property string printState: "idle"

    /**
     * 打印进度（0.0-1.0）
     */
    property real progress: 0.0

    /**
     * 当前打印文件名
     */
    property string currentFileName: ""

    // ===== 基类属性配置 =====
    title: "打印控制"
    widgetState: "idle"
    isInteractive: true

    // ===== 内容区域 =====
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingMedium

        // 状态显示区域
        Item {
            visible: root.printState !== "idle"
            Layout.fillWidth: true
            Layout.preferredHeight: Style.baseUnit * 3

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.spacingSmall

                // 文件名
                Text {
                    visible: root.currentFileName !== ""
                    text: root.currentFileName
                    font.pixelSize: Style.fontNormal
                    font.family: Style.fontFamily
                    color: Style.textPrimary
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: root.width - Style.spacingLarge * 2
                    Layout.alignment: Qt.AlignHCenter
                }

                // 进度条
                ProgressBar {
                    visible: root.printState === "printing" || root.printState === "paused"
                    from: 0
                    to: 1
                    value: root.progress
                    Layout.preferredWidth: root.width - Style.spacingLarge * 2
                    Layout.preferredHeight: Style.baseUnit * 0.5

                    background: Rectangle {
                        color: Style.bgCard
                        border.width: Style.borderThin
                        border.color: Style.border
                        radius: Style.radiusTiny
                    }

                    contentItem: Rectangle {
                        width: parent.visualPosition * parent.width
                        color: Style.getProgressColor(root.progress * 100)
                        radius: Style.radiusTiny
                    }
                }

                // 进度百分比
                Text {
                    visible: root.printState === "printing" || root.printState === "paused"
                    text: (root.progress * 100).toFixed(1) + "%"
                    font.pixelSize: Style.fontMedium
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // 按钮区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Idle 状态：超大"开始打印"按钮
            Button {
                visible: root.printState === "idle"
                anchors.fill: parent
                text: "开始打印"

                background: Rectangle {
                    color: parent.pressed ? Qt.darker(Style.success, 1.2) :
                           parent.hovered ? Qt.lighter(Style.success, 1.1) :
                           Style.success
                    radius: Style.radiusSmall
                    border.width: Style.borderThin
                    border.color: Qt.lighter(Style.success, 1.2)

                    Behavior on color {
                        ColorAnimation { duration: Style.durationFast }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamily
                    font.bold: true
                    color: Style.bgPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    console.log("PrintControlWidget: Start print clicked")
                    // TODO: Phase 6 - 打开文件选择对话框
                }
            }

            // Printing 状态：暂停/取消按钮
            RowLayout {
                visible: root.printState === "printing"
                anchors.fill: parent
                spacing: Style.spacingMedium

                Button {
                    text: "暂停"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.warning, 1.2) :
                               parent.hovered ? Qt.lighter(Style.warning, 1.1) :
                               Style.warning
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("PrintControlWidget: Pause clicked")
                        // TODO: Phase 6 - 暂停打印
                    }
                }

                Button {
                    text: "取消"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.error, 1.2) :
                               parent.hovered ? Qt.lighter(Style.error, 1.1) :
                               Style.error
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("PrintControlWidget: Cancel clicked")
                        // TODO: Phase 6 - 取消打印
                    }
                }
            }

            // Paused 状态：恢复/取消按钮
            RowLayout {
                visible: root.printState === "paused"
                anchors.fill: parent
                spacing: Style.spacingMedium

                Button {
                    text: "恢复"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.success, 1.2) :
                               parent.hovered ? Qt.lighter(Style.success, 1.1) :
                               Style.success
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("PrintControlWidget: Resume clicked")
                        // TODO: Phase 6 - 恢复打印
                    }
                }

                Button {
                    text: "取消"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(Style.error, 1.2) :
                               parent.hovered ? Qt.lighter(Style.error, 1.1) :
                               Style.error
                        radius: Style.radiusSmall
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamily
                        font.bold: true
                        color: Style.bgPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("PrintControlWidget: Cancel clicked")
                        // TODO: Phase 6 - 取消打印
                    }
                }
            }

            // Complete 状态：完成提示
            Text {
                visible: root.printState === "complete"
                anchors.centerIn: parent
                text: "✓ 打印完成"
                font.pixelSize: Style.fontXLarge
                font.family: Style.fontFamily
                font.bold: true
                color: Style.success
            }
        }
    }
}
