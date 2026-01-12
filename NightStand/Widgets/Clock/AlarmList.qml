import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

ListView {
    id: alarmList
    spacing: 10
    clip: true

    signal deleteAlarm(int alarmId)
    signal toggleAlarm(int alarmId)

    delegate: AlarmItem {
        width: alarmList.width
        alarmId: model.alarmId
        alarmTime: model.timeString
        alarmLabel: model.label
        alarmEnabled: model.enabled

        onToggleEnabled: alarmList.toggleAlarm(alarmId)
        onDeleteClicked: alarmList.deleteAlarm(alarmId)
    }

    // Empty state
    Text {
        anchors.centerIn: parent
        visible: alarmList.count === 0
        text: "No alarms set"
        font.pixelSize: 16
        color: UiStyle.subtextColor
    }
}
