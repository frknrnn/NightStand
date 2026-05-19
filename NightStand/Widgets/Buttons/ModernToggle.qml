import QtQuick
import "../../Style"

Item {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 80
    implicitHeight: 50

    Rectangle {
        id: track
        anchors.centerIn: parent
        width: 60
        height: 34
        radius: height / 2
        color: root.checked ? UiStyle.buttonProgress : UiStyle.innerCardColor
        border.width: 1
        border.color: root.checked ? UiStyle.buttonProgress : UiStyle.roundButtonColor

        Behavior on color {
            ColorAnimation { duration: 180 }
        }

        Rectangle {
            id: thumb
            width: 26
            height: 26
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 4 : 4
            color: root.checked ? UiStyle.white : UiStyle.subtextColor

            Behavior on x {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: 180 }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.toggled()
    }
}
