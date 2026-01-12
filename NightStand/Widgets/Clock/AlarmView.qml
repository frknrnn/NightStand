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
            id: alarmList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: alarmViewModel.alarmModel

            onDeleteAlarm: function(alarmId) {
                alarmViewModel.removeAlarm(alarmId)
            }

            onToggleAlarm: function(alarmId) {
                alarmViewModel.toggleEnabled(alarmId)
            }
        }

        AddAlarmButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            onClicked: addAlarmPopup.open()
        }
    }

    AddAlarmPopup {
        id: addAlarmPopup
        parent: Overlay.overlay

        onAlarmAdded: function(hour, minute, label) {
            alarmViewModel.addAlarm(hour, minute, label)
        }
    }
}
