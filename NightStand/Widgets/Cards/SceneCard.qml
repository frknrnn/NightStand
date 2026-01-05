// SceneCard.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../../Style"

Rectangle {
    property string sceneName: ""
    property string icon: ""
    property bool isActive: false

    color: isActive ? UiStyle.roundButtonColor : UiStyle.innerCardColor
    radius: 16
    border.color: isActive ? UiStyle.headerColor : UiStyle.transparent
    border.width: 2

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: icon
            font.pixelSize: 32
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: sceneName
            font.pixelSize: 14
            color: UiStyle.white
            Layout.alignment: Qt.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.isActive = !parent.isActive
    }
}
