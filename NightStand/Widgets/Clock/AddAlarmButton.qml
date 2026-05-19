import QtQuick
import "../../Style"

Rectangle {
    id: addButton

    signal clicked()

    implicitWidth: 140
    implicitHeight: 48

    radius: height / 2
    color: pressArea.pressed ? Qt.darker(UiStyle.headerColor, 1.15) : UiStyle.headerColor
    scale: pressArea.pressed ? 0.97 : 1.0

    Behavior on color {
        ColorAnimation { duration: 120 }
    }
    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "+"
            font.pixelSize: 22
            font.bold: true
            color: UiStyle.white
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Add Alarm"
            font.pixelSize: 16
            font.bold: true
            color: UiStyle.white
        }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        onClicked: addButton.clicked()
    }
}
