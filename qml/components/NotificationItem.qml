import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// 单个通知项 (Metro 风格)
Rectangle {
    id: notification
    width: parent.width
    height: contentLayout.height + Style.spacingMedium * 2
    color: getBackgroundColor()
    border.width: Style.borderMedium
    border.color: Style.divider

    property string notificationType: "info"  // "info", "success", "warning", "error"
    property string message: ""

    // 进入动画
    opacity: 0
    x: width  // 从右侧滑入
    Component.onCompleted: {
        slideInAnimation.start()
        autoHideTimer.start()
    }

    ParallelAnimation {
        id: slideInAnimation
        NumberAnimation { target: notification; property: "x"; to: 0; duration: Style.durationNormal; easing.type: Easing.OutCubic }
        NumberAnimation { target: notification; property: "opacity"; to: 1; duration: Style.durationNormal }
    }

    ParallelAnimation {
        id: slideOutAnimation
        NumberAnimation { target: notification; property: "x"; to: notification.width; duration: Style.durationNormal; easing.type: Easing.InCubic }
        NumberAnimation { target: notification; property: "opacity"; to: 0; duration: Style.durationNormal }
        onFinished: notification.destroy()
    }

    Timer {
        id: autoHideTimer
        interval: 3000  // 3秒后自动隐藏
        onTriggered: slideOutAnimation.start()
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: Style.spacingMedium
        spacing: Style.spacingMedium

        // 类型图标
        Label {
            text: getIcon()
            font.pixelSize: Style.fontLarge
            color: getIconColor()
            Layout.alignment: Qt.AlignVCenter
        }

        // 消息文本
        Label {
            text: message
            font.pixelSize: Style.fontSmall
            font.family: Style.fontFamily
            color: Style.textPrimary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        // 关闭按钮
        Label {
            text: "✕"
            font.pixelSize: Style.fontMedium
            color: Style.textSecondary
            Layout.alignment: Qt.AlignVCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    autoHideTimer.stop()
                    slideOutAnimation.start()
                }
            }
        }
    }

    function getBackgroundColor() {
        switch(notificationType) {
            case "success": return Style.success
            case "warning": return Style.warning
            case "error": return Style.error
            default: return Style.info
        }
    }

    function getIconColor() {
        return Style.bgPrimary
    }

    function getIcon() {
        switch(notificationType) {
            case "success": return "✓"
            case "warning": return "⚠"
            case "error": return "✕"
            default: return "ℹ"
        }
    }
}
