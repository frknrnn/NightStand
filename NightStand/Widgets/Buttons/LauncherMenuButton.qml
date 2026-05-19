import QtQuick
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

        Image {
            anchors.centerIn: parent
            source: root.iconSource
            sourceSize.width: 28
            sourceSize.height: 28
            width: 28
            height: 28
            smooth: true
            mipmap: true
            fillMode: Image.PreserveAspectFit
        }

        MouseArea {
            id: pressArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
