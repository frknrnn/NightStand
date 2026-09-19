import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../Style"
import "../../Widgets/Clock"

Item {
    id: timerView

    // Push the view model's duration into the tumblers without looping back
    function syncPicker() {
        picker.setDuration(timerViewModel.selectedHours,
                           timerViewModel.selectedMinutes,
                           timerViewModel.selectedSeconds)
    }

    Component.onCompleted: Qt.callLater(syncPicker)

    Connections {
        target: timerViewModel

        // Presets and cancel change the selection from the C++ side
        function onSelectedDurationChanged() {
            timerView.syncPicker()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        anchors.topMargin: 12
        spacing: 8

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            horizontalAlignment: Text.AlignHCenter
            text: "Timer"
            font.pixelSize: 22
            font.bold: true
            color: UiStyle.subtextColor
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 18

            // ---------------------------------------------- left card
            Rectangle {
                Layout.preferredWidth: 210
                Layout.maximumWidth: 210
                Layout.fillHeight: true
                radius: 20
                color: UiStyle.cardPanelColor

                // Idle: quick-set presets
                TimerPresets {
                    anchors.fill: parent
                    anchors.margins: 16
                    visible: opacity > 0
                    opacity: timerViewModel.idle ? 1.0 : 0.0
                    enabled: timerViewModel.idle
                    presetModel: timerViewModel.presets

                    Behavior on opacity {
                        NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
                    }

                    onPresetClicked: function(index) {
                        timerViewModel.applyPreset(index)
                    }
                }

                // Active: run info
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 2
                    visible: opacity > 0
                    opacity: timerViewModel.idle ? 0.0 : 1.0

                    Behavior on opacity {
                        NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
                    }

                    Text {
                        text: "Total"
                        font.pixelSize: 13
                        color: UiStyle.subtextColor
                    }

                    Text {
                        text: timerViewModel.totalText
                        font.family: "Consolas, Menlo, Monaco, monospace"
                        font.pixelSize: 26
                        font.bold: true
                        color: UiStyle.textColor
                    }

                    Item { Layout.preferredHeight: 20 }

                    Text {
                        text: "Ends at"
                        font.pixelSize: 13
                        color: UiStyle.subtextColor
                        visible: timerViewModel.running
                    }

                    Text {
                        text: timerViewModel.endsAtText
                        font.family: "Consolas, Menlo, Monaco, monospace"
                        font.pixelSize: 32
                        font.bold: true
                        color: UiStyle.headerColor
                        visible: timerViewModel.running
                    }

                    Item { Layout.preferredHeight: 20 }

                    // State chip
                    Rectangle {
                        Layout.preferredWidth: stateLabel.implicitWidth + 24
                        Layout.preferredHeight: 32
                        radius: 16
                        color: "transparent"
                        border.width: 1
                        border.color: timerViewModel.finished ? UiStyle.red
                                                              : timerViewModel.paused ? UiStyle.subtextColor
                                                                                      : UiStyle.buttonProgress

                        Behavior on border.color {
                            ColorAnimation { duration: 250 }
                        }

                        Text {
                            id: stateLabel
                            anchors.centerIn: parent
                            text: timerViewModel.finished ? "Time's up"
                                                          : timerViewModel.paused ? "Paused" : "Running"
                            font.pixelSize: 13
                            font.bold: true
                            color: parent.border.color
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // ---------------------------------------------- center
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TimerDurationPicker {
                    id: picker
                    anchors.fill: parent
                    visible: opacity > 0
                    enabled: timerViewModel.idle
                    opacity: timerViewModel.idle ? 1.0 : 0.0
                    scale: timerViewModel.idle ? 1.0 : 0.94

                    Behavior on opacity {
                        NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                    }

                    onDurationPicked: function(hours, minutes, seconds) {
                        timerViewModel.setSelectedDuration(hours, minutes, seconds)
                    }
                }

                TimerRing {
                    id: ring
                    anchors.fill: parent
                    visible: opacity > 0
                    opacity: timerViewModel.idle ? 0.0 : 1.0
                    scale: timerViewModel.idle ? 0.94 : 1.0

                    progress: timerViewModel.progress
                    timeText: timerViewModel.remainingText
                    showsHours: timerViewModel.showsHours
                    dimmed: timerViewModel.paused
                    pulsing: timerViewModel.finished

                    progressColor: UiStyle.headerColor

                    // Progress is 0 when finished, so the track carries the alarm colour
                    trackColor: timerViewModel.finished ? UiStyle.red : UiStyle.roundButtonColor

                    captionText: timerViewModel.finished ? "Time's up"
                                                         : timerViewModel.paused ? "Paused"
                                                                                 : timerViewModel.endsAtText.length > 0
                                                                                   ? "Ends " + timerViewModel.endsAtText
                                                                                   : ""

                    Behavior on opacity {
                        NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                    }
                }
            }

            // ---------------------------------------------- right column
            TimerControls {
                Layout.preferredWidth: 210
                Layout.maximumWidth: 210
                Layout.fillHeight: true

                idle: timerViewModel.idle
                running: timerViewModel.running
                paused: timerViewModel.paused
                finished: timerViewModel.finished
                canStart: timerViewModel.canStart

                onPrimaryClicked: timerViewModel.toggleStartPause()
                onAddMinuteClicked: timerViewModel.addOneMinute()

                onSecondaryClicked: {
                    if (timerViewModel.idle)
                        timerViewModel.setSelectedDuration(0, 0, 0)
                    else
                        timerViewModel.cancel()
                }
            }
        }
    }
}
