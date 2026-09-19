import QtQuick
import "../Common"
import "../../Style"

Item {
    id: root

    property url iconSource: ""
    property int buttonSize: 64

    signal clicked()

    implicitWidth: buttonSize
    implicitHeight: buttonSize

    Rectangle {
        id: body
        anchors.fill: parent
        radius: 18
        color: UiStyle.roundButtonColor

        scale: pressArea.pressed ? 0.95 : 1.0
        opacity: pressArea.pressed ? 0.85 : 1.0

        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        ThemedIcon {
            anchors.centerIn: parent
            source: root.iconSource
            size: 28
            color: UiStyle.textColor
        }

        MouseArea {
            id: pressArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
