import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

/**
 * Metro风格对话框组件
 * 统一的对话框样式，支持自定义内容
 */
Dialog {
    id: dialog

    // 公共属性
    property string dialogTitle: ""
    property string message: ""
    property color headerColor: Style.bgSecondary
    property color titleColor: Style.textPrimary
    property string acceptText: "OK"
    property string rejectText: "CANCEL"
    property color acceptColor: Style.info
    property color rejectColor: Style.bgCard

    // 对话框设置
    modal: true
    anchors.centerIn: parent
    width: Math.min(parent.width * 0.5, Style.baseUnit * 22)

    // 背景
    background: Rectangle {
        color: Style.bgCard
        border.width: Style.borderMedium
        border.color: Style.divider
        radius: Style.radiusSmall
    }

    // 标题栏
    header: Rectangle {
        width: parent.width
        height: Style.baseUnit * 3
        color: headerColor
        radius: Style.radiusSmall

        Label {
            anchors.centerIn: parent
            text: dialogTitle.toUpperCase()
            font.pixelSize: Style.fontMedium
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 2
            color: titleColor
        }
    }

    // 内容区域
    contentItem: Item {
        implicitWidth: Style.baseUnit * 20
        implicitHeight: Style.baseUnit * 6

        Label {
            anchors.fill: parent
            anchors.margins: Style.spacingLarge
            text: message
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textPrimary
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // 按钮栏
    footer: DialogButtonBox {
        background: Rectangle {
            color: Style.bgSecondary
            radius: Style.radiusSmall
        }

        // Accept 按钮
        Button {
            text: acceptText
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 2
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

            background: Rectangle {
                color: acceptColor
                border.width: Style.borderThin
                border.color: Style.divider
                radius: Style.radiusSmall
            }

            contentItem: Label {
                text: parent.text
                font: parent.font
                color: Style.bgPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Reject 按钮
        Button {
            text: rejectText
            font.family: Style.fontFamily
            font.bold: true
            font.letterSpacing: 2
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            background: Rectangle {
                color: rejectColor
                border.width: Style.borderThin
                border.color: Style.divider
                radius: Style.radiusSmall
            }

            contentItem: Label {
                text: parent.text
                font: parent.font
                color: Style.textPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
