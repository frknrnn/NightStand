import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"
import "../../Widgets/Buttons"

Item {
    id: alarmCard

    property int alarmId: -1
    property string alarmTime: "00:00"
    property string alarmLabel: "Alarm"
    property bool alarmEnabled: false
    property var alarmRepeatDays: []

    signal toggleEnabled()
    signal deleteClicked()
    signal editClicked()

    implicitHeight: 130

    function repeatLabel() {
        if (!alarmRepeatDays || alarmRepeatDays.length === 0)
            return "One-time"
        if (alarmRepeatDays.length === 7)
            return "Every day"
        var sorted = alarmRepeatDays.slice().sort(function (a, b) { return a - b })
        var weekdays = [1, 2, 3, 4, 5]
        var weekend = [0, 6]
        if (sorted.length === 5 && sorted.every(function (d, i) { return d === weekdays[i] }))
            return "Weekdays"
        if (sorted.length === 2 && sorted[0] === 0 && sorted[1] === 6)
            return "Weekends"
        var names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var parts = []
        for (var i = 0; i < sorted.length; ++i)
            parts.push(names[sorted[i]])
        return parts.join(" ")
    }

    function isDayActive(day) {
        return alarmRepeatDays && alarmRepeatDays.indexOf(day) !== -1
    }

    // Long-press delete confirmation overlay
    Rectangle {
        id: deleteOverlay
        anchors.fill: parent
        radius: 18
        color: UiStyle.red
        opacity: deleteConfirm ? 1 : 0
        visible: opacity > 0
        z: 2

        property bool deleteConfirm: false

        Behavior on opacity {
            NumberAnimation { duration: 180 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: "Delete this alarm?"
                font.pixelSize: 18
                font.bold: true
                color: UiStyle.white
            }

            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 44
                radius: 22
                color: "transparent"
                border.color: UiStyle.white
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: UiStyle.white
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: deleteOverlay.deleteConfirm = false
                }
            }

            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 44
                radius: 22
                color: UiStyle.white

                Text {
                    anchors.centerIn: parent
                    text: "Delete"
                    color: UiStyle.red
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: removeAnim.start()
                }
            }
        }
    }

    // Main card
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 18
        color: UiStyle.cardPanelColor
        border.width: 1
        border.color: alarmEnabled ? UiStyle.headerColor : UiStyle.roundButtonColor
        scale: pressArea.pressed ? 0.97 : 1.0

        Behavior on border.color {
            ColorAnimation { duration: 200 }
        }
        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 220 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                Text {
                    text: alarmTime
                    font.pixelSize: 44
                    font.bold: true
                    color: alarmEnabled ? UiStyle.textColor : UiStyle.subtextColor

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: alarmLabel
                    font.pixelSize: 15
                    color: UiStyle.subtextColor
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }

                // Repeat days dots row
                RowLayout {
                    spacing: 5
                    Repeater {
                        model: [1, 2, 3, 4, 5, 6, 0]
                        delegate: Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: alarmCard.isDayActive(modelData) && alarmEnabled
                                   ? UiStyle.headerColor
                                   : UiStyle.roundButtonColor

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }

                    Text {
                        Layout.leftMargin: 6
                        text: alarmCard.repeatLabel()
                        font.pixelSize: 12
                        color: UiStyle.subtextColor
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                ModernToggle {
                    Layout.alignment: Qt.AlignRight
                    checked: alarmEnabled
                    onToggled: alarmCard.toggleEnabled()
                }
            }
        }

        MouseArea {
            id: pressArea
            anchors.fill: parent
            pressAndHoldInterval: 500
            onClicked: {
                if (!deleteOverlay.deleteConfirm)
                    alarmCard.editClicked()
            }
            onPressAndHold: deleteOverlay.deleteConfirm = true
        }
    }

    SequentialAnimation {
        id: removeAnim
        ParallelAnimation {
            NumberAnimation { target: card; property: "opacity"; to: 0; duration: 200 }
            NumberAnimation { target: card; property: "scale"; to: 0.9; duration: 200 }
        }
        NumberAnimation { target: alarmCard; property: "implicitHeight"; to: 0; duration: 180; easing.type: Easing.OutCubic }
        ScriptAction { script: alarmCard.deleteClicked() }
    }
}
