import QtQuick
import QtQuick.Layouts
import "../../Style"

Item {
    id: root

    // Stored as Sun=0 .. Sat=6 to match AlarmModel storage
    property var selectedDays: []

    function isSelected(day) {
        return selectedDays.indexOf(day) !== -1
    }

    function toggleDay(day) {
        var copy = selectedDays.slice()
        var idx = copy.indexOf(day)
        if (idx === -1)
            copy.push(day)
        else
            copy.splice(idx, 1)
        selectedDays = copy
    }

    function setDays(days) {
        selectedDays = days.slice()
    }

    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 10

        Text {
            text: "Repeat"
            font.pixelSize: 14
            color: UiStyle.subtextColor
        }

        // 7 day circles: Mon Tue Wed Thu Fri Sat Sun (display order)
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: [
                    { label: "M", day: 1 },
                    { label: "T", day: 2 },
                    { label: "W", day: 3 },
                    { label: "T", day: 4 },
                    { label: "F", day: 5 },
                    { label: "S", day: 6 },
                    { label: "S", day: 0 }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    radius: width / 2
                    color: root.isSelected(modelData.day) ? UiStyle.headerColor : UiStyle.innerCardColor
                    border.width: 1
                    border.color: root.isSelected(modelData.day) ? UiStyle.headerColor : UiStyle.roundButtonColor

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: 16
                        font.bold: true
                        color: root.isSelected(modelData.day) ? UiStyle.onHeaderColor : UiStyle.subtextColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.toggleDay(modelData.day)
                    }
                }
            }
        }

        // Quick presets
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { label: "Weekdays", days: [1, 2, 3, 4, 5] },
                    { label: "Weekend",  days: [0, 6] },
                    { label: "Every day", days: [0, 1, 2, 3, 4, 5, 6] }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 17
                    color: "transparent"
                    border.width: 1
                    border.color: UiStyle.roundButtonColor

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: 13
                        font.bold: true
                        color: UiStyle.textColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.setDays(modelData.days)
                    }
                }
            }
        }
    }
}
