import QtQuick
import QtQuick.Layouts
import "../../Style"

Item {
    id: display

    property int milliseconds: 0
    property bool running: false

    implicitWidth: row.implicitWidth + 40
    implicitHeight: 140

    function pad(n) { return n < 10 ? "0" + n : "" + n }

    readonly property int totalMinutes: Math.floor(milliseconds / 60000)
    readonly property int seconds: Math.floor((milliseconds % 60000) / 1000)
    readonly property int hundredths: Math.floor((milliseconds % 1000) / 10)

    // Soft glow behind the digits
    Rectangle {
        anchors.centerIn: parent
        width: row.width + 60
        height: row.height + 40
        radius: 24
        color: "transparent"
        border.width: 2
        border.color: running ? UiStyle.headerColor : UiStyle.roundButtonColor
        opacity: running ? 0.4 : 0.15

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 250 }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: pad(totalMinutes) + ":" + pad(seconds)
            font.family: "Consolas, Menlo, Monaco, monospace"
            font.pixelSize: 110
            font.bold: true
            color: UiStyle.textColor
        }

        Text {
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 18
            text: "." + pad(hundredths)
            font.family: "Consolas, Menlo, Monaco, monospace"
            font.pixelSize: 42
            font.bold: true
            color: UiStyle.subtextColor
        }
    }

    Timer {
        interval: 10
        running: display.running
        repeat: true
        onTriggered: display.milliseconds += 10
    }
}
