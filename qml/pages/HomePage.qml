import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components"

/**
 * HomePage - 主页
 *
 * 显示常用功能 Widget 和功能入口图标。
 * 布局: 左侧 60% 显示 4 个 Widget，右侧 40% 显示功能图标网格。
 *
 * 此页面是导航栈的根页面（root），用户总是可以通过 HOME 按钮返回此页面。
 *
 * Widget 区域（左侧）:
 * - 温度 Widget（热端/热床）
 * - 风扇 Widget（打印冷却）
 * - LED Widget（仓灯）
 * - 打印控制 Widget（开始/暂停/取消）
 *
 * 功能图标区域（右侧）:
 * - 设置、控制、文件、AFC、移动、更多等功能入口
 *
 * 使用示例:
 *   StackView {
 *       initialItem: HomePage { }
 *   }
 */
Page {
    id: root

    // ===== 页面属性 =====

    /**
     * StackView 引用（用于导航）
     */
    property StackView stackView: StackView.view

    /**
     * 打印状态数据
     */
    property string printState: "standby"
    property real printProgress: 0.0
    property string printFileName: ""

    // ===== 数据绑定 =====
    Connections {
        target: app ? app.printer : null

        function onPrinterStateChanged(state) {
            root.printState = state
        }

        function onPrintProgressChanged(data) {
            root.printProgress = data.progress || 0.0
            root.printFileName = data.filename || ""
        }
    }

    // ===== 页面背景 =====
    background: Rectangle {
        color: Style.bgPrimary
    }

    // ===== 主布局 =====
    RowLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingLarge

        // ===== 左侧：Widget 区域（60%） =====
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 950
            color: Style.bgSecondary
            radius: Style.radiusSmall

            // 2x2 网格布局
            GridLayout {
                anchors.fill: parent
                anchors.margins: Style.spacingMedium
                columns: 2
                rows: 2
                columnSpacing: Style.spacingMedium
                rowSpacing: Style.spacingMedium

                // Widget 1: 温度显示（热端）
                TempWidget {
                    widgetId: "temp_hotend"
                    heaterName: "热端"
                    heaterType: "extruder"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Widget 2: 温度显示（热床）
                TempWidget {
                    widgetId: "temp_bed"
                    heaterName: "热床"
                    heaterType: "bed"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Widget 3: 风扇控制
                FanWidget {
                    widgetId: "fan_part_cooling"
                    fanName: "冷却风扇"
                    fanSpeed: 0.0  // TODO: Phase 5 - 绑定到真实数据
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Widget 4: LED 控制
                LedWidget {
                    widgetId: "led_chamber"
                    ledName: "仓灯"
                    ledBrightness: 0.0  // TODO: Phase 5 - 绑定到真实数据
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        // ===== 分隔线（增强视觉效果）=====
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: Style.borderMedium
            color: Style.border

            // 添加阴影效果
            Rectangle {
                anchors.left: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Style.borderThin
                color: Qt.rgba(0, 0, 0, 0.1)
            }
        }

        // ===== 右侧：功能区域（40%） =====
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true  // Fill remaining space

            ColumnLayout {
                anchors.fill: parent
                spacing: Style.spacingMedium

                // ===== 上部区域（60%）：打印控制 =====
                PrintControlWidget {
                    widgetId: "print_control"
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.6
                }

                // ===== 下部区域（40%）：4个图标横向排列 =====
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Style.spacingMedium

                    // 功能图标 1: 设置
                    FunctionIcon {
                        iconId: "settings"
                        label: "设置"
                        iconName: "settings"
                        targetPage: "settings"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onIconClicked: (iconId, targetPage) => {
                            var appWindow = root.Window.window
                            if (appWindow && appWindow.pageRegistry) {
                                appWindow.pageRegistry.navigateTo(targetPage)
                            }
                        }
                    }

                    // 功能图标 2: 控制 (使用 fine-tune 图标，代表精细调整)
                    FunctionIcon {
                        iconId: "control"
                        label: "控制"
                        iconName: "fine-tune"  // KlipperScreen 无 control.svg，使用 fine-tune.svg
                        targetPage: "control"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onIconClicked: (iconId, targetPage) => {
                            var appWindow = root.Window.window
                            if (appWindow && appWindow.pageRegistry) {
                                appWindow.pageRegistry.navigateTo(targetPage)
                            }
                        }
                    }

                    // 功能图标 3: 移动 (XYZ轴移动)
                    FunctionIcon {
                        iconId: "move"
                        label: "移动"
                        iconName: "move"
                        targetPage: "move"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onIconClicked: (iconId, targetPage) => {
                            var appWindow = root.Window.window
                            if (appWindow && appWindow.pageRegistry) {
                                appWindow.pageRegistry.navigateTo(targetPage)
                            }
                        }
                    }

                    // 功能图标 4: 文件
                    FunctionIcon {
                        iconId: "files"
                        label: "文件"
                        iconName: "files"
                        targetPage: "files"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onIconClicked: (iconId, targetPage) => {
                            var appWindow = root.Window.window
                            if (appWindow && appWindow.pageRegistry) {
                                appWindow.pageRegistry.navigateTo(targetPage)
                            }
                        }
                    }
                }
            }
        }
    }

    // ===== 生命周期钩子 =====
    StackView.onActivated: {
        console.log("HomePage activated")
    }

    StackView.onDeactivated: {
        console.log("HomePage deactivated")
    }

    Component.onCompleted: {
        console.log("HomePage created, stackView:", stackView)
    }
}
