import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Metro 风格通知 Toast (屏幕右上角)
Item {
    id: root
    anchors.fill: parent

    property int maxNotifications: 3  // 最多同时显示3个通知

    // 通知列表
    Column {
        id: notificationColumn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Style.spacingLarge
        spacing: Style.spacingSmall
        width: Style.baseUnit * 20
        z: 999  // 高层级，但低于 ErrorOverlay
    }

    // 显示通知的函数
    function show(type, message) {
        // 限制通知数量
        if (notificationColumn.children.length >= maxNotifications) {
            // 移除最旧的通知
            notificationColumn.children[0].destroy()
        }

        // 创建新通知
        var component = Qt.createComponent("NotificationItem.qml")
        if (component.status === Component.Ready) {
            var notification = component.createObject(notificationColumn, {
                "notificationType": type,
                "message": message
            })
        } else {
            console.error("Failed to create notification:", component.errorString())
        }
    }
}
