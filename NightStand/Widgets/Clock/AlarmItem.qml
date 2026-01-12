import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Item {
    id: alarmItem

    property int alarmId: -1
    property string alarmTime: "00:00"
    property string alarmLabel: "Alarm"
    property bool alarmEnabled: false

    signal toggleEnabled()
    signal deleteClicked()

    height: 80
    clip: true

    // Delete background (revealed on swipe)
    Rectangle {
        id: deleteBackground
        anchors.fill: parent
        radius: 12
        color: UiStyle.red

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            spacing: 8

            Text {
                text: "Delete"
                font.pixelSize: 16
                font.bold: true
                color: UiStyle.white
                opacity: Math.min(1, -contentCard.x / 80)
            }

            Text {
                text: "🗑"
                font.pixelSize: 20
                opacity: Math.min(1, -contentCard.x / 80)
            }
        }
    }

    // Main content card (swipeable)
    Rectangle {
        id: contentCard
        width: parent.width
        height: parent.height
        radius: 12
        color: UiStyle.cardPanelColor

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: alarmTime
                    font.pixelSize: 28
                    font.bold: true
                    color: alarmEnabled ? UiStyle.textColor : UiStyle.subtextColor

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                Text {
                    text: alarmLabel
                    font.pixelSize: 14
                    color: UiStyle.subtextColor
                }
            }

            Switch {
                checked: alarmEnabled
                onToggled: alarmItem.toggleEnabled()
            }
        }

        MouseArea {
            id: swipeArea
            anchors.fill: parent
            drag.target: contentCard
            drag.axis: Drag.XAxis
            drag.minimumX: -120
            drag.maximumX: 0

            onReleased: {
                if (contentCard.x < -80) {
                    // Trigger delete with animation
                    deleteAnimation.start()
                } else {
                    // Snap back
                    contentCard.x = 0
                }
            }

            onClicked: {
                if (contentCard.x < 0) {
                    contentCard.x = 0
                }
            }
        }
    }

    // Delete animation sequence
    SequentialAnimation {
        id: deleteAnimation

        ParallelAnimation {
            NumberAnimation {
                target: contentCard
                property: "x"
                to: -alarmItem.width
                duration: 250
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: contentCard
                property: "opacity"
                to: 0
                duration: 250
            }
        }

        NumberAnimation {
            target: alarmItem
            property: "height"
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }

        ScriptAction {
            script: alarmItem.deleteClicked()
        }
    }
}
