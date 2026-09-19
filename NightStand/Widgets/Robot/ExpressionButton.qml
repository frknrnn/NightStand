import QtQuick
import "../../Style"

// İfade butonu: ikon olarak o ifadenin donmuş mini robot suratını gösterir.
Item {
    id: root

    property string expressionId: "mutlu"
    property int buttonSize: 84
    property bool selected: false

    signal clicked()

    implicitWidth: buttonSize
    implicitHeight: buttonSize

    Rectangle {
        id: bodyRect
        anchors.fill: parent
        radius: root.buttonSize * 0.24
        color: root.selected ? UiStyle.innerCardColor : UiStyle.roundButtonColor
        border.width: 2
        border.color: root.selected ? UiStyle.headerColor : UiStyle.transparent

        scale: pressArea.pressed ? 0.95 : (root.selected ? 1.05 : 1.0)
        opacity: pressArea.pressed ? 0.9 : 1.0

        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on color { ColorAnimation { duration: 180 } }
        Behavior on border.color { ColorAnimation { duration: 180 } }

        RobotCharacter {
            id: face
            anchors.centerIn: parent
            expression: root.expressionId
            animated: false
            interactive: false
            faceSize: root.buttonSize * 0.60
            mouthSegments: 9
        }

        MouseArea {
            id: pressArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
