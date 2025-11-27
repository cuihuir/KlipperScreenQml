import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.6

            // 2x2 网格布局
            GridLayout {
                anchors.fill: parent
                columns: 2
                rows: 2
                columnSpacing: Style.spacingMedium
                rowSpacing: Style.spacingMedium

                // Widget 1: 温度显示（热端）
                TempWidget {
                    widgetId: "temp_hotend"
                    heaterName: "热端"
                    currentTemp: 0.0  // TODO: Phase 4 - 绑定到真实数据
                    targetTemp: 0.0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Widget 2: 温度显示（热床）
                TempWidget {
                    widgetId: "temp_bed"
                    heaterName: "热床"
                    currentTemp: 0.0  // TODO: Phase 4 - 绑定到真实数据
                    targetTemp: 0.0
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

        // ===== 分隔线 =====
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: Style.borderThin
            color: Style.divider
        }

        // ===== 右侧：功能区域（40%） =====
        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4

            ColumnLayout {
                anchors.fill: parent
                spacing: Style.spacingLarge

                // 顶部：打印控制 Widget（占据约 40% 高度）
                PrintControlWidget {
                    widgetId: "print_control"
                    printState: "idle"  // TODO: Phase 6 - 绑定到真实数据
                    progress: 0.0
                    currentFileName: ""
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.4
                }

                // 分隔线
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.borderThin
                    color: Style.divider
                }

                // 底部：功能图标网格（占据约 60% 高度）
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rows: 2
                    columnSpacing: Style.spacingMedium
                    rowSpacing: Style.spacingMedium

                    // 功能图标 1: 设置
                    FunctionIcon {
                        iconId: "settings"
                        label: "设置"
                        iconEmoji: "⚙️"
                        targetPage: "settings"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onIconClicked: (iconId, targetPage) => {
                            console.log("Navigating to:", targetPage)
                            // 通过 StackView 导航到目标页面
                            if (root.stackView) {
                                root.stackView.push(Qt.resolvedUrl("../pages/" + targetPage.charAt(0).toUpperCase() + targetPage.slice(1) + "Page.qml"))
                                navigationManager.pushPage(targetPage)
                            }
                        }
                    }

                    // 功能图标 2: 控制
                    FunctionIcon {
                        iconId: "control"
                        label: "控制"
                        iconEmoji: "🎮"
                        targetPage: "control"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onIconClicked: (iconId, targetPage) => {
                            console.log("Navigating to:", targetPage)
                            // 通过 StackView 导航到目标页面
                            if (root.stackView) {
                                root.stackView.push(Qt.resolvedUrl("../pages/" + targetPage.charAt(0).toUpperCase() + targetPage.slice(1) + "Page.qml"))
                                navigationManager.pushPage(targetPage)
                            }
                        }
                    }

                    // 功能图标 3: 文件
                    FunctionIcon {
                        iconId: "files"
                        label: "文件"
                        iconEmoji: "📁"
                        targetPage: "files"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        onIconClicked: (iconId, targetPage) => {
                            console.log("Navigating to:", targetPage)
                            // 通过 StackView 导航到目标页面
                            if (root.stackView) {
                                root.stackView.push(Qt.resolvedUrl("../pages/" + targetPage.charAt(0).toUpperCase() + targetPage.slice(1) + "Page.qml"))
                                navigationManager.pushPage(targetPage)
                            }
                        }
                    }

                    // 功能图标 4: AFC（暂时禁用）
                    FunctionIcon {
                        iconId: "afc"
                        label: "AFC"
                        iconEmoji: "🔄"
                        targetPage: "afc"
                        enabled: false  // 未来功能
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // 功能图标 5: 移动
                    FunctionIcon {
                        iconId: "move"
                        label: "移动"
                        iconEmoji: "🧭"
                        targetPage: "move"
                        enabled: false  // 未来功能
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // 功能图标 6: 更多
                    FunctionIcon {
                        iconId: "more"
                        label: "更多"
                        iconEmoji: "⋯"
                        targetPage: "more"
                        enabled: false  // 未来功能
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
