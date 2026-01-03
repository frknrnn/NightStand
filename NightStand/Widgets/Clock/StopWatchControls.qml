import QtQuick
import QtQuick.Layouts
import "../../Style"
import "../../Widgets/Clock"


RowLayout {
    id: controls

    property bool running: false

    signal startStop()
    signal reset()
    signal lap()

    spacing: 20

    StopWatchButton {
        width: 80
        height: 80
        text: "Reset"
        isPrimary: false

        onClicked: controls.reset()
    }

    StopWatchButton {
        width: 100
        height: 100
        text: running ? "Stop" : "Start"
        isPrimary: true

        onClicked: controls.startStop()
    }

    StopWatchButton {
        width: 80
        height: 80
        text: "Lap"
        isPrimary: false

        onClicked: controls.lap()
    }
}
