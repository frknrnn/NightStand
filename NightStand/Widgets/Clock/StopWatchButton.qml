import QtQuick
import "../../Style"

Rectangle {
    id: button

    property string text: ""
    property bool isPrimary: false
    property bool enabled: true
    property color accentColor: UiStyle.headerColor

    signal clicked()

    radius: width / 2
    color: isPrimary ? accentColor : UiStyle.roundButtonColor
    border.color: isPrimary ? "transparent" : accentColor
    border.width: isPrimary ? 0 : 2
    opacity: enabled ? 1.0 : 0.4
    scale: pressArea.pressed && enabled ? 0.92 : 1.0

    Behavior on color {
        ColorAnimation { duration: 200 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 200 }
    }
    Behavior on scale {
        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 180 }
    }

    Text {
        anchors.centerIn: parent
        text: button.text
        font.pixelSize: isPrimary ? 22 : 16
        font.bold: true
        color: isPrimary ? UiStyle.white : UiStyle.textColor
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        enabled: button.enabled
        onClicked: button.clicked()
    }
}
