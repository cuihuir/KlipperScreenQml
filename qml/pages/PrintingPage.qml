import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../components"

/**
 * PrintingPage - Sp�ub`M&	
 *
 * >:SMSp����ۦ��6	�
 * SM:`M&��( Phase 6 �t��
 */
Page {
    id: root

    // ===== ub^' =====
    property var printer: null
    property StackView stackView: StackView.view

    // ===== �� =====
    signal backToHomeRequested()
    signal placeholderRequested(string featureName)

    // ===== ub�o =====
    background: Rectangle {
        color: Style.bgPrimary
    }

    // ===== `M&�� =====
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.spacingLarge

        Text {
            text: "Sp�ub"
            font.pixelSize: Style.fontXLarge
            font.family: Style.fontFamily
            font.bold: true
            color: Style.textPrimary
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "`M& - ( Phase 6 ��	"
            font.pixelSize: Style.fontNormal
            font.family: Style.fontFamily
            color: Style.textSecondary
            Layout.alignment: Qt.AlignHCenter
        }

        MetroButton {
            text: "��;u"
            buttonColor: Style.accent
            textColor: Style.bgPrimary
            Layout.alignment: Qt.AlignHCenter

            onClicked: {
                root.backToHomeRequested()
            }
        }
    }

    // ===== }h�P =====
    StackView.onActivated: {
        console.log("PrintingPage activated")
    }

    StackView.onDeactivated: {
        console.log("PrintingPage deactivated")
    }

    Component.onCompleted: {
        console.log("PrintingPage created")
    }
}
