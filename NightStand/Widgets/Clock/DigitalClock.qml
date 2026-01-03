import QtQuick
import "../../Style"


Text {
    id: digitalClock
    font.pixelSize: 72
    font.bold: true
    color: UiStyle.textColor

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var date = new Date()
            digitalClock.text = Qt.formatTime(date, "hh:mm:ss")
        }
    }
}
