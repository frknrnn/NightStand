import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"


Rectangle {
    id: alarmItem

    property string alarmTime: "00:00"
    property string alarmLabel: "Alarm"
    property bool alarmEnabled: false

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

        Switch {
            checked: alarmEnabled
            onToggled: alarmItem.alarmEnabled = checked
        }
    }
}
