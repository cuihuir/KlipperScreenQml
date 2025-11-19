import QtQuick
import QtQuick.Controls
import ".."

/**
 * Metro风格按钮组件
 * 统一的按钮样式，支持不同颜色和尺寸
 */
Rectangle {
    id: button

    // 公共属性
    property string text: ""
    property color buttonColor: Style.bgSecondary
    property color textColor: Style.textPrimary
    property color borderColor: Style.divider
    property real borderWidth: Style.borderThin
    property bool enabled: true
    property real fontSize: Style.fontNormal
    property bool bold: true
    property real letterSpacing: 1

    // 信号
    signal clicked()

    // 样式
    color: enabled ? buttonColor : Style.bgCard
    border.width: borderWidth
    border.color: enabled ? borderColor : Style.divider
    radius: Style.radiusSmall
    opacity: enabled ? 1.0 : 0.5

    // 文本
    Label {
        anchors.centerIn: parent
        text: button.text.toUpperCase()
        font.pixelSize: fontSize
        font.family: Style.fontFamily
        font.bold: bold
        font.letterSpacing: letterSpacing
        color: enabled ? textColor : Style.textDisabled
    }

    // Hover 效果
    Rectangle {
        anchors.fill: parent
        color: Style.textPrimary
        opacity: 0
        radius: parent.radius

        states: State {
            name: "hovered"
            when: mouseArea.containsMouse && enabled
            PropertyChanges { target: parent.children[1]; opacity: 0.1 }
        }

        Behavior on opacity {
            NumberAnimation { duration: Style.durationFast }
        }
    }

    // 鼠标交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: if (enabled) button.clicked()
    }

    // 按下效果
    states: State {
        name: "pressed"
        when: mouseArea.pressed && enabled
        PropertyChanges { target: button; scale: 0.98 }
    }

    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
}
