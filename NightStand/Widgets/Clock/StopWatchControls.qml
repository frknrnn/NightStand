import QtQuick
import QtQuick.Layouts
import "../../Style"
import "../../Widgets/Clock"

RowLayout {
    id: controls

    property bool running: false
    property bool hasTime: false

    signal startStop()
    signal reset()
    signal lap()

    spacing: 32

    StopWatchButton {
        Layout.preferredWidth: 96
        Layout.preferredHeight: 96
        text: "Reset"
        isPrimary: false
        enabled: running || hasTime

        onClicked: controls.reset()
    }

    StopWatchButton {
        Layout.preferredWidth: 132
        Layout.preferredHeight: 132
        text: running ? "Stop" : "Start"
        isPrimary: true
        accentColor: running ? UiStyle.red : UiStyle.buttonProgress

        onClicked: controls.startStop()
    }

    StopWatchButton {
        Layout.preferredWidth: 96
        Layout.preferredHeight: 96
        text: "Lap"
        isPrimary: false
        enabled: running

        onClicked: controls.lap()
    }
}
