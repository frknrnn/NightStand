import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"
import "../../Widgets/Clock"

Item {
    id: alarmView

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Alarms"
            font.pixelSize: 24
            font.bold: true
            color: UiStyle.textColor
        }

        AlarmList {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        AddAlarmButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }
    }
}
