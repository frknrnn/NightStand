import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Common"
import "../../Style"

Rectangle {
    id: root

    property string title: ""
    property url iconSource: ""
    property int iconSize: 34
    property color accentColor: UiStyle.headerColor

    signal clicked()

    radius: 16
    color: UiStyle.innerCardColor
    border.color: pressArea.containsMouse ? accentColor : UiStyle.transparent
    border.width: 2

    scale: pressArea.pressed ? 0.96 : 1.0
    opacity: pressArea.pressed ? 0.9 : 1.0

    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        ThemedIcon {
            source: root.iconSource
            size: root.iconSize
            color: UiStyle.textColor
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: root.title
            font.pixelSize: 14
            font.bold: true
            color: UiStyle.textColor
            Layout.alignment: Qt.AlignHCenter
        }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
