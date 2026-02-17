import QtQuick
import QtQuick.Layouts

Rectangle {
    id: nightModeOverlay
    anchors.fill: parent
    color: "#000000"
    visible: appController.nightMode
    z: 1000

    // Exit night mode when tapped anywhere
    MouseArea {
        anchors.fill: parent
        onClicked: {
            appController.toggleNightMode()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 15

        // Digital Clock - dimmed for night mode
        Text {
            id: nightClock
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 120
            font.bold: true
            font.family: "Arial"
            color: "#404040"  // Dimmed gray for night mode

            Timer {
                interval: 1000
                running: nightModeOverlay.visible
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var date = new Date()
                    nightClock.text = Qt.formatTime(date, "HH:mm")
                }
            }
        }

        // Date Display - dimmed for night mode
        Text {
            id: nightDate
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 28
            color: "#303030"  // Even more dimmed for date

            Timer {
                interval: 60000  // Update every minute
                running: nightModeOverlay.visible
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var date = new Date()
                    nightDate.text = Qt.formatDate(date, "dddd, d MMMM yyyy")
                }
            }
        }
    }

    // Fade in/out animation
    Behavior on visible {
        enabled: false
    }

    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
}
