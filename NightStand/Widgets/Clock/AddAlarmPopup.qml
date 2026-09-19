import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Popup {
    id: addAlarmPopup

    property int selectedHour: 7
    property int selectedMinute: 0
    property string alarmLabel: ""
    property var selectedDays: []
    property int editingAlarmId: -1

    readonly property bool isEditing: editingAlarmId >= 0

    signal alarmAdded(int hour, int minute, string label, var days)
    signal alarmUpdated(int alarmId, int hour, int minute, string label, var days)

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    width: Math.min(parent.width * 0.78, 760)
    height: Math.min(parent.height * 0.92, 540)

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    background: Rectangle {
        color: UiStyle.cardPanelColor
        radius: 22
        border.width: 1
        border.color: UiStyle.roundButtonColor
    }

    function openForCreate() {
        editingAlarmId = -1
        selectedHour = 7
        selectedMinute = 0
        alarmLabel = ""
        selectedDays = []
        hourTumbler.currentIndex = 7
        minuteTumbler.currentIndex = 0
        labelField.text = ""
        daysSelector.setDays([])
        open()
    }

    function openForEdit(id, hour, minute, label, days) {
        editingAlarmId = id
        selectedHour = hour
        selectedMinute = minute
        alarmLabel = label
        selectedDays = days || []
        hourTumbler.currentIndex = hour
        minuteTumbler.currentIndex = minute
        labelField.text = label
        daysSelector.setDays(days || [])
        open()
    }

    contentItem: ColumnLayout {
        spacing: 16

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: isEditing ? "Edit Alarm" : "New Alarm"
            font.pixelSize: 24
            font.bold: true
            color: UiStyle.textColor
        }

        // Two-column body
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            // Left: time picker
            Rectangle {
                Layout.preferredWidth: parent.width * 0.55
                Layout.fillHeight: true
                color: UiStyle.innerCardColor
                radius: 16

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Tumbler {
                        id: hourTumbler
                        model: 24
                        currentIndex: selectedHour
                        wrap: true
                        visibleItemCount: 5
                        width: 120
                        height: 240

                        delegate: Text {
                            text: modelData < 10 ? "0" + modelData : modelData
                            font.pixelSize: hourTumbler.currentIndex === index ? 40 : 24
                            font.bold: hourTumbler.currentIndex === index
                            color: hourTumbler.currentIndex === index ? UiStyle.textColor : UiStyle.subtextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (hourTumbler.visibleItemCount / 2)

                            Behavior on font.pixelSize {
                                NumberAnimation { duration: 120 }
                            }
                        }

                        onCurrentIndexChanged: selectedHour = currentIndex
                    }

                    Text {
                        text: ":"
                        font.pixelSize: 48
                        font.bold: true
                        color: UiStyle.headerColor
                    }

                    Tumbler {
                        id: minuteTumbler
                        model: 60
                        currentIndex: selectedMinute
                        wrap: true
                        visibleItemCount: 5
                        width: 120
                        height: 240

                        delegate: Text {
                            text: modelData < 10 ? "0" + modelData : modelData
                            font.pixelSize: minuteTumbler.currentIndex === index ? 40 : 24
                            font.bold: minuteTumbler.currentIndex === index
                            color: minuteTumbler.currentIndex === index ? UiStyle.textColor : UiStyle.subtextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (minuteTumbler.visibleItemCount / 2)

                            Behavior on font.pixelSize {
                                NumberAnimation { duration: 120 }
                            }
                        }

                        onCurrentIndexChanged: selectedMinute = currentIndex
                    }
                }
            }

            // Right: label + days
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    color: UiStyle.innerCardColor
                    radius: 14
                    border.width: 1
                    border.color: labelField.activeFocus ? UiStyle.headerColor : UiStyle.roundButtonColor

                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }

                    TextField {
                        id: labelField
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        placeholderText: "Label (optional)"
                        placeholderTextColor: UiStyle.subtextColor
                        color: UiStyle.textColor
                        font.pixelSize: 16
                        verticalAlignment: TextInput.AlignVCenter
                        background: Rectangle { color: "transparent" }

                        onTextChanged: alarmLabel = text
                    }
                }

                RepeatDaysSelector {
                    id: daysSelector
                    Layout.fillWidth: true

                    onSelectedDaysChanged: addAlarmPopup.selectedDays = selectedDays
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 28
                color: "transparent"
                border.width: 1
                border.color: UiStyle.roundButtonColor

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.pixelSize: 18
                    font.bold: true
                    color: UiStyle.textColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: addAlarmPopup.close()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 28
                color: saveArea.pressed ? Qt.darker(UiStyle.headerColor, 1.15) : UiStyle.headerColor

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: isEditing ? "Update" : "Save"
                    font.pixelSize: 18
                    font.bold: true
                    color: UiStyle.onHeaderColor
                }

                MouseArea {
                    id: saveArea
                    anchors.fill: parent
                    onClicked: {
                        if (isEditing)
                            alarmUpdated(editingAlarmId, selectedHour, selectedMinute, alarmLabel, selectedDays)
                        else
                            alarmAdded(selectedHour, selectedMinute, alarmLabel, selectedDays)
                        addAlarmPopup.close()
                    }
                }
            }
        }
    }
}
