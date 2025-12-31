// NavButton.qml
import QtQuick 2.15

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
            color: isActive ? "#6366f1" : "#7a8fa8"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width
            height: 3
            radius: 1.5
            color: "#6366f1"
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
