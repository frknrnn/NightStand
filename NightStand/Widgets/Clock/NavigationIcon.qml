import QtQuick
import "../../Style"

Item {
    id: navIcon

    property string labelText: ""
    property bool isActive: false

    signal clicked()

    width: textLabel.implicitWidth + 20
    height: 50

    Text {
        id: textLabel
        anchors.centerIn: parent
        text: navIcon.labelText
        font.pixelSize: isActive ? 18 : 14
        font.weight: isActive ? Font.Bold : Font.Normal
        color: isActive ? UiStyle.headerColor : UiStyle.subtextColor
        opacity: isActive ? 1.0 : 0.6

        Behavior on font.pixelSize {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        scale: isActive ? 1.1 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: navIcon.clicked()
    }
}
