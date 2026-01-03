import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"


ListView {
    id: alarmList
    spacing: 10
    clip: true

    model: ListModel {
        ListElement { time: "07:00"; label: "Wake Up"; enabled: true }
        ListElement { time: "12:30"; label: "Lunch"; enabled: false }
        ListElement { time: "18:00"; label: "Dinner"; enabled: true }
    }

    delegate: AlarmItem {
        width: ListView.view.width
        alarmTime: model.time
        alarmLabel: model.label
        alarmEnabled: model.enabled

        onEnabledChanged: model.enabled = alarmEnabled
    }
}
