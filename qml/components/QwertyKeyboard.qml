import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// QWERTY 键盘组件 - 支持字母、数字、符号输入
Rectangle {
    id: root

    property string inputValue: ""
    property string title: "SEARCH"
    property bool shiftMode: false
    property bool symbolMode: false

    signal confirmed(string value)
    signal cancelled()
    signal textChanged(string value)

    color: Style.bgCard
    border.width: Style.borderThin
    border.color: Style.divider

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingSmall

        // 顶部行：标题 | 输入框 | DEL
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingMedium

            // 标题
            Label {
                Layout.preferredWidth: Style.baseUnit * 10
                text: title
                font.pixelSize: Style.fontMedium
                font.family: Style.fontFamily
                font.bold: true
                font.letterSpacing: 2
                color: Style.textPrimary
                horizontalAlignment: Text.AlignLeft
            }

            // 输入框显示
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 5
                color: Style.bgSecondary
                border.width: Style.borderMedium
                border.color: Style.accent

                Label {
                    anchors.centerIn: parent
                    text: inputValue || "..."
                    font.pixelSize: Style.fontXLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: inputValue ? Style.accent : Style.textDisabled
                }
            }

            // DEL 键
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 8
                Layout.preferredHeight: Style.baseUnit * 5
                color: Style.warning
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "⌫"
                    font.pixelSize: Style.fontLarge
                    font.family: Style.fontFamilyMono
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: backspace()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: Style.borderThin
            color: Style.divider
        }

        // 第一行: 数字键 1-0
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Repeater {
                id: row1Keys

                property var numberModel: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                property var symbolModel: ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")"]

                model: symbolMode ? symbolModel : numberModel
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData)
                    }
                }
            }
        }

        // 第二行: Q-P / 符号1
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Repeater {
                id: row2Keys

                property var symbolModel: ["`", "~", "+", "=", "{", "}", "[", "]", "\u005C", "|"]
                property var upperModel: ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
                property var lowerModel: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]

                model: symbolMode ? symbolModel : (shiftMode ? upperModel : lowerModel)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData)
                    }
                }
            }
        }

        // 第三行: A-L / 符号2
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Item { Layout.preferredWidth: Style.baseUnit * 2 }

            Repeater {
                id: row3Keys

                property var symbolModel: ["<", ">", ":", ";", "\"", "'", ",", ".", "/", "?"]
                property var upperModel: ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
                property var lowerModel: ["a", "s", "d", "f", "g", "h", "j", "k", "l"]

                model: symbolMode ? symbolModel : (shiftMode ? upperModel : lowerModel)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData)
                    }
                }
            }

            Item { Layout.preferredWidth: Style.baseUnit * 2 }
        }

        // 第四行: Z-M + Shift
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            // Shift 键
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 8
                Layout.preferredHeight: Style.baseUnit * 4
                color: shiftMode ? Style.accent : Style.bgSecondary
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "⇧ Shift"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: shiftMode ? Style.bgPrimary : Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toggleShift()
                }
            }

            Repeater {
                id: row4Keys

                property var symbolModel: ["~", "!", "@", "#", "$", "%", "^", "&", "*"]
                property var upperModel: ["Z", "X", "C", "V", "B", "N", "M"]
                property var lowerModel: ["z", "x", "c", "v", "b", "n", "m"]

                model: symbolMode ? symbolModel : (shiftMode ? upperModel : lowerModel)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.baseUnit * 4
                    color: Style.bgSecondary
                    border.width: Style.borderThin
                    border.color: Style.divider

                    Label {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Style.fontLarge
                        font.family: Style.fontFamilyMono
                        font.bold: true
                        color: Style.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appendChar(modelData)
                    }
                }
            }
        }

        // 第五行: 符号按钮 | 空格 | 确认
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            // 符号切换按钮
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 10
                Layout.preferredHeight: Style.baseUnit * 4
                color: symbolMode ? Style.accent : Style.bgSecondary
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: symbolMode ? "ABC" : "符"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: symbolMode ? Style.bgPrimary : Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toggleSymbols()
                }
            }

            // 空格
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.bgSecondary
                border.width: Style.borderThin
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "SPACE"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appendChar(" ")
                }
            }

            // 确认按钮
            Rectangle {
                Layout.preferredWidth: Style.baseUnit * 10
                Layout.preferredHeight: Style.baseUnit * 4
                color: Style.success
                border.width: Style.borderMedium
                border.color: Style.divider

                Label {
                    anchors.centerIn: parent
                    text: "✓ 确认"
                    font.pixelSize: Style.fontMedium
                    font.bold: true
                    color: Style.bgPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: confirm()
                }
            }
        }
    }

    // 辅助函数
    function appendChar(ch) {
        inputValue += ch
        root.textChanged(inputValue)

        // 输入字符后自动关闭 Shift（模拟真实键盘行为）
        if (shiftMode && /[A-Za-z]/.test(ch)) {
            toggleShift()
        }
    }

    function backspace() {
        if (inputValue.length > 0) {
            inputValue = inputValue.slice(0, -1)
            root.textChanged(inputValue)
        }
    }

    function toggleShift() {
        shiftMode = !shiftMode
        console.log("Shift mode:", shiftMode)
    }

    function toggleSymbols() {
        symbolMode = !symbolMode
        shiftMode = false  // 切换符号时关闭 Shift
        console.log("Symbol mode:", symbolMode)
    }

    function confirm() {
        root.confirmed(inputValue)
    }

    function clear() {
        inputValue = ""
        root.textChanged(inputValue)
        shiftMode = false
        symbolMode = false
    }
}