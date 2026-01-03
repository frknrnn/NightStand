import QtQuick
import QtQuick.Layouts
import "../../Style"
import "../../Widgets/Clock"



Item {
    id: stopwatchView

    QtObject {
        id: stopwatchData
        property int milliseconds: 0
        property bool running: false
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 40

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Stopwatch"
            font.pixelSize: 24
            font.bold: true
            color: UiStyle.textColor
        }

        StopWatchDisplay {
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
                stopwatchData.milliseconds = 0
                stopwatchData.running = false
            }
        }
    }
}
