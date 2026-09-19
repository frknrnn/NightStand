import QtQuick
import QtQuick.Layouts
import "../../Style"
import "../../Widgets/Clock"

ColumnLayout {
    id: controls

    property bool idle: true
    property bool running: false
    property bool paused: false
    property bool finished: false
    property bool canStart: false

    signal primaryClicked()
    signal addMinuteClicked()
    signal secondaryClicked()

    spacing: 16

    Item { Layout.fillHeight: true }

    StopWatchButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 132
        Layout.preferredHeight: 132
        isPrimary: true
        enabled: !controls.idle || controls.canStart

        text: controls.running ? "Pause"
                               : controls.paused ? "Resume"
                                                 : controls.finished ? "Dismiss" : "Start"

        accentColor: controls.running ? UiStyle.headerColor
                                      : controls.finished ? UiStyle.headerColor
                                                          : UiStyle.buttonProgress

        onClicked: controls.primaryClicked()
    }

    StopWatchButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 104
        Layout.preferredHeight: 104
        text: "+1:00"
        isPrimary: false
        enabled: controls.running || controls.paused

        onClicked: controls.addMinuteClicked()
    }

    StopWatchButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 104
        Layout.preferredHeight: 104
        isPrimary: false
        text: controls.idle ? "Reset" : "Cancel"
        accentColor: controls.idle ? UiStyle.headerColor : UiStyle.red
        enabled: !controls.idle || controls.canStart

        onClicked: controls.secondaryClicked()
    }

    Item { Layout.fillHeight: true }
}
