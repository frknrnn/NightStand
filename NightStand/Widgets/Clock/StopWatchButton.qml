import QtQuick
import "../../Style"

Rectangle {
    id: button

    property string text: ""
    property bool isPrimary: false

    signal clicked()

    radius: width / 2
    color: isPrimary ? UiStyle.headerColor : UiStyle.roundButtonColor
    border.color: isPrimary ? "transparent" : UiStyle.headerColor
    border.width: isPrimary ? 0 : 2

    Text {
        anchors.centerIn: parent
        text: button.text
        font.pixelSize: isPrimary ? 18 : 14
        font.bold: isPrimary
        color: isPrimary ? "white" : UiStyle.textColor
    }

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }
}
