import QtQuick
import "../../Style"


Text {
    id: display

    property int milliseconds: 0
    property bool running: false

    text: {
        var ms = milliseconds
        var minutes = Math.floor(ms / 60000)
        var seconds = Math.floor((ms % 60000) / 1000)
        var millis = Math.floor((ms % 1000) / 10)
        return (minutes < 10 ? "0" : "") + minutes + ":" +
               (seconds < 10 ? "0" : "") + seconds + ":" +
               (millis < 10 ? "0" : "") + millis
    }
    font.pixelSize: 56
    font.bold: true
    color: UiStyle.textColor

    Timer {
        interval: 10
        running: display.running
        repeat: true
        onTriggered: display.milliseconds += 10
    }
}
