import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

GridView {
    id: alarmGrid

    signal deleteAlarm(int alarmId)
    signal toggleAlarm(int alarmId)
    signal editAlarm(int alarmId, int hour, int minute, string label, var days)

    cellWidth: Math.floor(width / 2)
    cellHeight: 142
    clip: true
    cacheBuffer: 200

    add: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
        }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; duration: 220; easing.type: Easing.OutCubic }
    }

    delegate: Item {
        width: alarmGrid.cellWidth
        height: alarmGrid.cellHeight

        AlarmCard {
            anchors.fill: parent
            anchors.margins: 6

            alarmId: model.alarmId
            alarmTime: model.timeString
            alarmLabel: model.label
            alarmEnabled: model.enabled
            alarmRepeatDays: model.repeatDays || []

            onToggleEnabled: alarmGrid.toggleAlarm(alarmId)
            onDeleteClicked: alarmGrid.deleteAlarm(alarmId)
            onEditClicked: {
                var time = model.time
                var hour = time ? time.getHours() : parseInt(model.timeString.split(":")[0])
                var minute = time ? time.getMinutes() : parseInt(model.timeString.split(":")[1])
                alarmGrid.editAlarm(alarmId, hour, minute, model.label, model.repeatDays || [])
            }
        }
    }

    // Empty state
    Column {
        anchors.centerIn: parent
        spacing: 10
        visible: alarmGrid.count === 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "⏰"
            font.pixelSize: 56
            color: UiStyle.subtextColor
            opacity: 0.6
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "No alarms yet"
            font.pixelSize: 20
            font.bold: true
            color: UiStyle.textColor
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Tap “+ Add Alarm” to create your first one"
            font.pixelSize: 14
            color: UiStyle.subtextColor
        }
    }
}
