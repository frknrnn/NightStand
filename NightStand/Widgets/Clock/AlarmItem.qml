import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: alarmItem

    property int alarmId: -1
    property string alarmTime: "00:00"
    property string alarmLabel: "Alarm"
    property bool alarmEnabled: false

    signal toggleEnabled()
    signal deleteClicked()

    height: 80
    radius: 12
    color: UiStyle.cardPanelColor

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: alarmTime
                font.pixelSize: 28
                font.bold: true
                color: alarmEnabled ? UiStyle.textColor : UiStyle.subtextColor
            }

            Text {
                text: alarmLabel
                font.pixelSize: 14
                color: UiStyle.subtextColor
            }
        }

        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: deleteMouseArea.pressed ? UiStyle.red : "transparent"

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 24
                font.bold: true
                color: UiStyle.red
                visible: !deleteMouseArea.pressed
            }

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 24
                font.bold: true
                color: UiStyle.white
                visible: deleteMouseArea.pressed
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                onClicked: alarmItem.deleteClicked()
            }
        }

        Switch {
            checked: alarmEnabled
            onToggled: alarmItem.toggleEnabled()
        }
    }
}
