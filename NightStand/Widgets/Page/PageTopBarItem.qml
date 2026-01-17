import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Shapes
import "../../Style"

Item {
    id: header
    //property alias title: labelText.text
    signal backClicked()
    height: 50

    QQC2.Button {
        id: backButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.topMargin: 0
        anchors.leftMargin: 0
        height: 50
        width: height
        Rectangle{
            anchors.fill:parent
            color:UiStyle.cardPanelColor
        }
        icon.width:  50
        icon.height: 50
        icon.source: UiStyle.iconPath("back")
        icon.color: UiStyle.headerColor
        onClicked: header.backClicked()
    }

    transform: Translate {
        Behavior on y { NumberAnimation { } }
        y: header.enabled ? 0 : -52
    }

}
