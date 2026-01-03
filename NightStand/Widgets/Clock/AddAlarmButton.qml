import QtQuick
import "../../Style"

Rectangle {
    id: addButton

    signal clicked()

    radius: 25
    color: UiStyle.headerColor

    Text {
        anchors.centerIn: parent
        text: "+ Add Alarm"
        font.pixelSize: 16
        font.bold: true
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: addButton.clicked()
    }
}
