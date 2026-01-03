import QtQuick
import "../../Style"

Item {
    id: navIcon

    property string iconText: ""
    property bool isActive: false

    signal clicked()

    width: 50
    height: 50

    Rectangle {
        anchors.centerIn: parent
        width: 40
        height: 40
        radius: 20
        color: isActive ? UiStyle.headerColor : "transparent"

        Text {
            anchors.centerIn: parent
            text: navIcon.iconText
            font.pixelSize: 24
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: navIcon.clicked()
    }
}
