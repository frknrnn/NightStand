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
    }

    ListModel {
        id: lapModel
    }

    function formatTime(ms) {
        var minutes = Math.floor(ms / 60000)
        var seconds = Math.floor((ms % 60000) / 1000)
        var millis = Math.floor((ms % 1000) / 10)
        return (minutes < 10 ? "0" : "") + minutes + ":" +
               (seconds < 10 ? "0" : "") + seconds + ":" +
               (millis < 10 ? "0" : "") + millis
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Stopwatch"
            font.pixelSize: 24
            font.bold: true
            color: UiStyle.textColor
        }

        StopWatchDisplay {
            id: stopwatchDisplay
            Layout.alignment: Qt.AlignHCenter
            milliseconds: stopwatchData.milliseconds
            running: stopwatchData.running

            onMillisecondsChanged: stopwatchData.milliseconds = milliseconds
        }

        StopWatchControls {
            Layout.alignment: Qt.AlignHCenter
            running: stopwatchData.running

            onStartStop: stopwatchData.running = !stopwatchData.running

            onReset: {
                stopwatchData.running = false
                stopwatchData.milliseconds = 0
                stopwatchDisplay.milliseconds = 0
                lapModel.clear()
            }

            onLap: {
                if (stopwatchData.running || stopwatchData.milliseconds > 0) {
                    var lapNumber = lapModel.count + 1
                    var currentTime = stopwatchData.milliseconds
                    var previousTime = lapModel.count > 0 ? lapModel.get(lapModel.count - 1).totalTime : 0
                    var lapTime = currentTime - previousTime

                    lapModel.append({
                        "lapNumber": lapNumber,
                        "lapTime": lapTime,
                        "totalTime": currentTime
                    })
                }
            }
        }

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

                delegate: Rectangle {
                    width: lapListView.width
                    height: 50
                    radius: 8
                    color: UiStyle.innerCardColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16

                        Text {
                            text: "Lap " + model.lapNumber
                            font.pixelSize: 16
                            font.bold: true
                            color: UiStyle.textColor
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: formatTime(model.lapTime)
                            font.pixelSize: 14
                            color: UiStyle.subtextColor
                        }

                        Text {
                            text: formatTime(model.totalTime)
                            font.pixelSize: 16
                            font.bold: true
                            color: UiStyle.textColor
                        }
                    }
                }
            }
        }
    }
}
