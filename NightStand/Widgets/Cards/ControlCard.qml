import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property string roomName: "Room"
    property string category: "Lights"
    property int brightness: 50

    color: "#223548"
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
                color: "#7a8fa8"
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: roomName
                font.pixelSize: 16
                font.bold: true
                color: "white"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: brightness + "%"
                font.pixelSize: 18
                font.bold: true
                color: "white"
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
                    color: "#4ade80"
                    radius: 18
                }
            }

            RoundButton {
                implicitWidth: 36
                implicitHeight: 36
                text: "🌙"
                background: Rectangle {
                    color: "#2a3f5f"
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
                    color: "#6366f1"
                    opacity: 0.3

                    Rectangle {
                        width: parent.width * (parent.parent.value / 100)
                        height: parent.height
                        radius: 4
                        color: "#6366f1"
                    }
                }

                handle: Rectangle {
                    x: parent.visualPosition * (parent.width - width)
                    y: (parent.height - height) / 2
                    width: 20
                    height: 20
                    radius: 10
                    color: "white"
                }
            }

            RoundButton {
                implicitWidth: 36
                implicitHeight: 36
                text: "☀️"
                background: Rectangle {
                    color: "#2a3f5f"
                    radius: 18
                }
            }

            RoundButton {
                implicitWidth: 36
                implicitHeight: 36
                text: "⚙️"
                background: Rectangle {
                    color: "#2a3f5f"
                    radius: 18
                }
            }
        }
    }
}
