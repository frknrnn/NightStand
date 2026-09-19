import QtQuick
import "../../Style"

// Robotun konuşma balonu. Metin değişince eski metin yukarı süzülüp kaybolur,
// yenisi aşağıdan yumuşak bir yaylanmayla oturur.
Item {
    id: bubble

    property string text: ""
    property real maxWidth: 560

    property real textOpacity: 1
    property real swapY: 0
    property bool ready: false

    implicitWidth: Math.max(180, Math.min(maxWidth, label.implicitWidth + 52))
    implicitHeight: 70

    Behavior on implicitWidth { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

    onTextChanged: {
        if (!ready) {
            label.text = text
            return
        }
        swap.restart()
    }

    Component.onCompleted: {
        label.text = bubble.text
        ready = true
    }

    // Kuyruk gövdeden ÖNCE gelir ki gövde iç yarısını örtsün (dikiş izi olmaz)
    Rectangle {
        width: 18
        height: 18
        rotation: 45
        color: UiStyle.cardPanelColor
        x: bubble.width / 2 - width / 2
        y: bubbleBody.height - height / 2
    }

    Rectangle {
        id: bubbleBody
        width: parent.width
        height: parent.height - 10
        radius: 18
        color: UiStyle.cardPanelColor

        Text {
            id: label
            anchors.fill: parent
            anchors.margins: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 19
            color: UiStyle.textColor
            opacity: bubble.textOpacity
            transform: Translate { y: bubble.swapY }
        }
    }

    SequentialAnimation {
        id: swap
        ParallelAnimation {
            NumberAnimation { target: bubble; property: "textOpacity"; to: 0; duration: 120; easing.type: Easing.InQuad }
            NumberAnimation { target: bubble; property: "swapY"; to: -9; duration: 120; easing.type: Easing.InQuad }
        }
        ScriptAction {
            script: {
                label.text = bubble.text
                bubble.swapY = 9
            }
        }
        ParallelAnimation {
            NumberAnimation { target: bubble; property: "textOpacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
            NumberAnimation { target: bubble; property: "swapY"; to: 0; duration: 260; easing.type: Easing.OutBack }
        }
    }
}
