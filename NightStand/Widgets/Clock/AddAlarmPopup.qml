import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Popup {
    id: addAlarmPopup

    property int selectedHour: 7
    property int selectedMinute: 0
    property string alarmLabel: ""

    signal alarmAdded(int hour, int minute, string label)

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    width: Math.min(parent.width * 0.9, 350)
    height: 400

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    background: Rectangle {
        color: UiStyle.cardPanelColor
        radius: 20
    }

    contentItem: ColumnLayout {
        spacing: 20

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Add Alarm"
            font.pixelSize: 22
            font.bold: true
            color: UiStyle.textColor
        }

        // Time Picker
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: UiStyle.innerCardColor
            radius: 12

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                // Hour Tumbler
                Column {
                    spacing: 5

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Hour"
                        font.pixelSize: 12
                        color: UiStyle.subtextColor
                    }

                    Tumbler {
                        id: hourTumbler
                        model: 24
                        currentIndex: selectedHour
                        wrap: true
                        visibleItemCount: 3
                        width: 70
                        height: 80

                        delegate: Text {
                            text: modelData < 10 ? "0" + modelData : modelData
                            font.pixelSize: hourTumbler.currentIndex === index ? 28 : 18
                            font.bold: hourTumbler.currentIndex === index
                            color: hourTumbler.currentIndex === index ? UiStyle.textColor : UiStyle.subtextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (hourTumbler.visibleItemCount / 2)
                        }

                        onCurrentIndexChanged: selectedHour = currentIndex
                    }
                }

                Text {
                    text: ":"
                    font.pixelSize: 32
                    font.bold: true
                    color: UiStyle.textColor
                }

                // Minute Tumbler
                Column {
                    spacing: 5

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Minute"
                        font.pixelSize: 12
                        color: UiStyle.subtextColor
                    }

                    Tumbler {
                        id: minuteTumbler
                        model: 60
                        currentIndex: selectedMinute
                        wrap: true
                        visibleItemCount: 3
                        width: 70
                        height: 80

                        delegate: Text {
                            text: modelData < 10 ? "0" + modelData : modelData
                            font.pixelSize: minuteTumbler.currentIndex === index ? 28 : 18
                            font.bold: minuteTumbler.currentIndex === index
                            color: minuteTumbler.currentIndex === index ? UiStyle.textColor : UiStyle.subtextColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (minuteTumbler.visibleItemCount / 2)
                        }

                        onCurrentIndexChanged: selectedMinute = currentIndex
                    }
                }
            }
        }

        // Label Input
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: UiStyle.innerCardColor
            radius: 12

            TextField {
                id: labelField
                anchors.fill: parent
                anchors.margins: 5
                placeholderText: "Alarm label (optional)"
                placeholderTextColor: UiStyle.subtextColor
                color: UiStyle.textColor
                font.pixelSize: 16
                background: Rectangle {
                    color: "transparent"
                }

                onTextChanged: alarmLabel = text
            }
        }

        Item { Layout.fillHeight: true }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                radius: 22
                color: UiStyle.innerCardColor

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.pixelSize: 16
                    font.bold: true
                    color: UiStyle.textColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        resetPopup()
                        addAlarmPopup.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                radius: 22
                color: UiStyle.headerColor

                Text {
                    anchors.centerIn: parent
                    text: "Save"
                    font.pixelSize: 16
                    font.bold: true
                    color: UiStyle.white
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        alarmAdded(selectedHour, selectedMinute, alarmLabel)
                        resetPopup()
                        addAlarmPopup.close()
                    }
                }
            }
        }
    }

    function resetPopup() {
        selectedHour = 7
        selectedMinute = 0
        alarmLabel = ""
        hourTumbler.currentIndex = 7
        minuteTumbler.currentIndex = 0
        labelField.text = ""
    }

    onOpened: {
        labelField.forceActiveFocus()
    }
}
