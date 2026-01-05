import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../Style"

Rectangle {
    property string roomName: "Room"
    property string category: "Lights"
    property int brightness: 50

    color: UiStyle.innerCardColor
    radius: 12

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: category
                font.pixelSize: 12
                color: UiStyle.subtextColor
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: roomName
                font.pixelSize: 16
                font.bold: true
                color: UiStyle.white
            }

            Item { Layout.fillWidth: true }

            Text {
                text: brightness + "%"
                font.pixelSize: 18
                font.bold: true
                color: UiStyle.white
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            RoundButton {
                implicitWidth: 36
                implicitHeight: 36
                text: "💡"
                background: Rectangle {
                    color: UiStyle.buttonProgress
                    radius: 18
                }
            }

            RoundButton {
                implicitWidth: 36
                implicitHeight: 36
                text: "🌙"
                background: Rectangle {
                    color: UiStyle.roundButtonColor
                    radius: 18
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: brightness

                background: Rectangle {
                    height: 8
                    radius: 4
                    color: UiStyle.headerColor
                    opacity: 0.3

                    Rectangle {
                        width: parent.width * (parent.parent.value / 100)
                        height: parent.height
                        radius: 4
                        color: UiStyle.headerColor
                    }
                }

                handle: Rectangle {
                    x: parent.visualPosition * (parent.width - width)
                    y: (parent.height - height) / 2
                    width: 20
                    height: 20
                    radius: 10
                    color: UiStyle.white
                }
            }

            RoundButton {
                implicitWidth: 36
                implicitHeight: 36
                text: "☀️"
                background: Rectangle {
                    color: UiStyle.roundButtonColor
                    radius: 18
                }
            }

            RoundButton {
                implicitWidth: 36
                implicitHeight: 36
                text: "⚙️"
                background: Rectangle {
                    color: UiStyle.roundButtonColor
                    radius: 18
                }
            }
        }
    }
}
