import QtQuick
import QtQuick.Layouts

Rectangle {
    id: nightModeOverlay
    anchors.fill: parent
    color: "#000000"
    // Control visibility through opacity for smooth transitions
    // visible stays true during fade-out animation
    visible: opacity > 0 || appController.nightMode
    opacity: appController.nightMode ? 1.0 : 0.0
    z: 1000

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    // Exit night mode when tapped anywhere
    MouseArea {
        anchors.fill: parent
        enabled: appController.nightMode
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
                running: appController.nightMode
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
                running: appController.nightMode
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var date = new Date()
                    nightDate.text = Qt.formatDate(date, "dddd, d MMMM yyyy")
                }
            }
        }
    }

}
