import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../Style"
import "../../Widgets/Clock"

Item {
    id: stopwatchView

    QtObject {
        id: stopwatchData
        property int milliseconds: 0
        property bool running: false
        property int fastestLapMs: -1
        property int slowestLapMs: -1
    }

    ListModel {
        id: lapModel
    }

    function formatTime(ms) {
        var minutes = Math.floor(ms / 60000)
        var seconds = Math.floor((ms % 60000) / 1000)
        var millis = Math.floor((ms % 1000) / 10)
        return (minutes < 10 ? "0" : "") + minutes + ":" +
               (seconds < 10 ? "0" : "") + seconds + "." +
               (millis < 10 ? "0" : "") + millis
    }

    function recomputeExtremes() {
        if (lapModel.count === 0) {
            stopwatchData.fastestLapMs = -1
            stopwatchData.slowestLapMs = -1
            return
        }
        var fastest = lapModel.get(0).lapTime
        var slowest = lapModel.get(0).lapTime
        for (var i = 1; i < lapModel.count; ++i) {
            var t = lapModel.get(i).lapTime
            if (t < fastest) fastest = t
            if (t > slowest) slowest = t
        }
        stopwatchData.fastestLapMs = fastest
        stopwatchData.slowestLapMs = slowest
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Stopwatch"
            font.pixelSize: 22
            font.bold: true
            color: UiStyle.subtextColor
        }

        StopWatchDisplay {
            id: stopwatchDisplay
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 160
            milliseconds: stopwatchData.milliseconds
            running: stopwatchData.running

            onMillisecondsChanged: stopwatchData.milliseconds = milliseconds
        }

        StopWatchControls {
            Layout.alignment: Qt.AlignHCenter
            running: stopwatchData.running
            hasTime: stopwatchData.milliseconds > 0

            onStartStop: stopwatchData.running = !stopwatchData.running

            onReset: {
                stopwatchData.running = false
                stopwatchData.milliseconds = 0
                stopwatchDisplay.milliseconds = 0
                lapModel.clear()
                recomputeExtremes()
            }

            onLap: {
                if (stopwatchData.running && stopwatchData.milliseconds > 0) {
                    var lapNumber = lapModel.count + 1
                    var currentTime = stopwatchData.milliseconds
                    // Total time of the most recently added lap (which is at index 0 since we insert at top)
                    var previousTime = lapModel.count > 0 ? lapModel.get(0).totalTime : 0
                    var lapTime = currentTime - previousTime

                    lapModel.insert(0, {
                        "lapNumber": lapNumber,
                        "lapTime": lapTime,
                        "totalTime": currentTime
                    })
                    recomputeExtremes()
                }
            }
        }

        // Lap list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            visible: lapModel.count > 0

            ListView {
                id: lapListView
                anchors.fill: parent
                model: lapModel
                clip: true
                spacing: 8
                cacheBuffer: 200

                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                }
                displaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
                }

                delegate: Rectangle {
                    id: lapCard
                    width: lapListView.width
                    height: 60
                    radius: 14
                    color: UiStyle.innerCardColor

                    readonly property bool isFastest: lapModel.count > 1 && model.lapTime === stopwatchData.fastestLapMs
                    readonly property bool isSlowest: lapModel.count > 1 && model.lapTime === stopwatchData.slowestLapMs
                    readonly property color accent: isFastest ? UiStyle.buttonProgress
                                                  : isSlowest ? UiStyle.red
                                                  : UiStyle.roundButtonColor

                    // Accent stripe on the left
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        width: 4
                        radius: 2
                        color: lapCard.accent
                        visible: lapCard.isFastest || lapCard.isSlowest
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 22
                        anchors.rightMargin: 18
                        spacing: 12

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Lap " + model.lapNumber
                                font.pixelSize: 16
                                font.bold: true
                                color: UiStyle.textColor
                            }

                            Text {
                                visible: lapCard.isFastest || lapCard.isSlowest
                                text: lapCard.isFastest ? "Fastest" : "Slowest"
                                font.pixelSize: 11
                                font.bold: true
                                color: lapCard.accent
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: formatTime(model.lapTime)
                            font.family: "Consolas, Menlo, Monaco, monospace"
                            font.pixelSize: 18
                            font.bold: true
                            color: lapCard.isFastest || lapCard.isSlowest
                                   ? lapCard.accent
                                   : UiStyle.textColor
                        }

                        Text {
                            text: formatTime(model.totalTime)
                            font.family: "Consolas, Menlo, Monaco, monospace"
                            font.pixelSize: 14
                            color: UiStyle.subtextColor
                            Layout.preferredWidth: 110
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
    }
}
