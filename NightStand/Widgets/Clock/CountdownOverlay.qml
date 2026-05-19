import QtQuick
import "../../Style"

Rectangle {
    id: root

    property bool running: false
    property int startValue: 3
    property int current: startValue

    signal finished()

    anchors.fill: parent
    color: "#000000"
    visible: opacity > 0
    opacity: running ? 0.7 : 0.0
    z: 1500

    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }

    onRunningChanged: {
        if (running) {
            current = startValue
            tickAnimation.restart()
            tickTimer.restart()
        } else {
            tickTimer.stop()
            tickAnimation.stop()
        }
    }

    // Block taps from passing through during countdown
    MouseArea {
        anchors.fill: parent
        enabled: root.running
    }

    Text {
        id: numberText
        anchors.centerIn: parent
        text: root.current > 0 ? root.current : ""
        font.pixelSize: 180
        font.bold: true
        font.family: "Arial"
        color: UiStyle.textColor
        opacity: 0
    }

    Timer {
        id: tickTimer
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            root.current = root.current - 1
            if (root.current <= 0) {
                root.running = false
                root.finished()
            } else {
                tickAnimation.restart()
            }
        }
    }

    SequentialAnimation {
        id: tickAnimation
        ParallelAnimation {
            NumberAnimation { target: numberText; property: "opacity"; from: 0; to: 1.0; duration: 200; easing.type: Easing.OutQuad }
            NumberAnimation { target: numberText; property: "scale"; from: 1.4; to: 1.0; duration: 250; easing.type: Easing.OutQuad }
        }
        PauseAnimation { duration: 350 }
        ParallelAnimation {
            NumberAnimation { target: numberText; property: "opacity"; from: 1.0; to: 0; duration: 200; easing.type: Easing.InQuad }
            NumberAnimation { target: numberText; property: "scale"; from: 1.0; to: 0.8; duration: 250; easing.type: Easing.InQuad }
        }
    }
}
