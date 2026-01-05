// NavButton.qml
import QtQuick 2.15
import "../../Style"

Item {
    property string text: ""
    property bool isActive: false

    width: buttonText.width
    height: 40

    Column {
        anchors.fill: parent
        spacing: 5

        Text {
            id: buttonText
            text: parent.parent.text
            font.pixelSize: 14
            color: isActive ? UiStyle.headerColor : UiStyle.subtextColor
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width
            height: 3
            radius: 1.5
            color: UiStyle.headerColor
            visible: isActive
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.isActive = true
    }
}
