import QtQuick
import QtQuick.Layouts
import "../../Style"

// Lives in Main.qml so the alert reaches the user from any page.
Rectangle {
    id: alertOverlay

    z: 2000
    color: UiStyle.black
    visible: opacity > 0
    opacity: timerViewModel.alerting ? 0.88 : 0.0
    enabled: timerViewModel.alerting

    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }

    // Red wash - the pattern of FlashOverlay, deliberately not its full white:
    // this fires at 3 AM on a nightstand.
    Rectangle {
        anchors.fill: parent
        color: UiStyle.red
        opacity: 0

        SequentialAnimation on opacity {
            running: timerViewModel.alerting
            loops: Animation.Infinite
            NumberAnimation { from: 0.0; to: 0.32; duration: 450; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 0.32; to: 0.0; duration: 450; easing.type: Easing.InOutQuad }
        }
    }

    // Tap anywhere to silence
    MouseArea {
        anchors.fill: parent
        enabled: timerViewModel.alerting
        onClicked: timerViewModel.dismissAlert()
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Time's up"
            font.pixelSize: 56
            font.bold: true
            color: UiStyle.white
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "00:00"
            font.family: "Consolas, Menlo, Monaco, monospace"
            font.pixelSize: 120
            font.bold: true
            color: UiStyle.white
        }

        Item { Layout.preferredHeight: 16 }

        // Explicit target for a half-asleep user
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 220
            Layout.preferredHeight: 72
            radius: 36
            color: dismissArea.pressed ? Qt.darker(UiStyle.white, 1.2) : UiStyle.white
            scale: dismissArea.pressed ? 0.96 : 1.0

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
            Behavior on scale {
                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: "Dismiss"
                font.pixelSize: 24
                font.bold: true
                color: UiStyle.black
            }

            MouseArea {
                id: dismissArea
                anchors.fill: parent
                onClicked: timerViewModel.dismissAlert()
            }
        }
    }

    // active goes false on dismiss -> the SoundEffect is destroyed -> playback stops
    Loader {
        active: timerViewModel.alerting
        source: "TimerAlertSound.qml"
    }
}
