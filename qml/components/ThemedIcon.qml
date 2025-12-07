// Themed Icon Component
// 主题化图标组件
import QtQuick

Image {
    id: root

    // Public properties / 公共属性
    property string iconName: ""
    property int iconSize: 48

    // Image properties / 图标属性
    width: iconSize
    height: iconSize
    sourceSize: Qt.size(iconSize, iconSize)

    // Performance optimization / 性能优化
    cache: true           // Enable caching
    asynchronous: true    // Async loading
    smooth: true          // High quality scaling

    // Load icon from ThemeProvider / 从主题提供者加载图标
    source: iconName && typeof ThemeProvider !== 'undefined'
            ? ThemeProvider.getIconPath(iconName)
            : ""

    // Error handling / 错误处理
    fillMode: Image.PreserveAspectFit

    // Optional: Show placeholder on error
    property bool showPlaceholder: true

    Rectangle {
        id: placeholder
        anchors.fill: parent
        visible: root.status === Image.Error && showPlaceholder
        color: "transparent"
        border.color: "#FF0000"
        border.width: 1
        opacity: 0.3

        Text {
            anchors.centerIn: parent
            text: "?"
            font.pixelSize: root.iconSize * 0.5
            color: "#FF0000"
        }
    }

    // Debug output / 调试输出
    Component.onCompleted: {
        if (!iconName) {
            console.warn("ThemedIcon: iconName not set")
        }
    }

    onStatusChanged: {
        if (status === Image.Error) {
            console.error("ThemedIcon: Failed to load icon:", iconName, "from", source)
        }
    }
}
