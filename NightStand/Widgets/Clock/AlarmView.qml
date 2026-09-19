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
        spacing: 14

        // Header row: title + Add button, right aligned
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item { Layout.fillWidth: true }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: "Alarms"
                    font.pixelSize: 26
                    font.bold: true
                    color: UiStyle.textColor
                }

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: alarmViewModel.enabledCount + " of " + alarmViewModel.totalCount + " active"
                    font.pixelSize: 13
                    color: UiStyle.subtextColor
                }
            }

            AddAlarmButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 160
                Layout.preferredHeight: 48

                onClicked: addAlarmPopup.openForCreate()
            }
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

            onEditAlarm: function(alarmId, hour, minute, label, days) {
                addAlarmPopup.openForEdit(alarmId, hour, minute, label, days)
            }
        }
    }

    AddAlarmPopup {
        id: addAlarmPopup
        parent: Overlay.overlay

        onAlarmAdded: function(hour, minute, label, days) {
            var newId = alarmViewModel.addAlarm(hour, minute, label, days)
        }

        onAlarmUpdated: function(alarmId, hour, minute, label, days) {
            alarmViewModel.updateAlarm(alarmId, hour, minute, label)
            alarmViewModel.setRepeatDays(alarmId, days)
        }
    }
}
