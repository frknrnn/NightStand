import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Item {
    id: picker

    signal durationPicked(int hours, int minutes, int seconds)

    // Guards the tumbler -> view model -> tumbler round trip
    property bool syncing: false

    function setDuration(hours, minutes, seconds) {
        syncing = true
        hourTumbler.currentIndex = hours
        minuteTumbler.currentIndex = minutes
        secondTumbler.currentIndex = seconds
        syncing = false
    }

    function emitDuration() {
        if (syncing)
            return

        picker.durationPicked(hourTumbler.currentIndex,
                              minuteTumbler.currentIndex,
                              secondTumbler.currentIndex)
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: UiStyle.innerCardColor

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                    text: "Hours"
                    font.pixelSize: 13
                    color: UiStyle.subtextColor
                }

                Item { Layout.preferredWidth: 20 }

                Text {
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                    text: "Minutes"
                    font.pixelSize: 13
                    color: UiStyle.subtextColor
                }

                Item { Layout.preferredWidth: 20 }

                Text {
                    Layout.preferredWidth: 120
                    horizontalAlignment: Text.AlignHCenter
                    text: "Seconds"
                    font.pixelSize: 13
                    color: UiStyle.subtextColor
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Tumbler {
                    id: hourTumbler
                    model: 24
                    wrap: true
                    visibleItemCount: 5
                    width: 120
                    height: 240

                    delegate: Text {
                        text: modelData < 10 ? "0" + modelData : modelData
                        font.pixelSize: hourTumbler.currentIndex === index ? 40 : 24
                        font.bold: hourTumbler.currentIndex === index
                        color: hourTumbler.currentIndex === index ? UiStyle.textColor : UiStyle.subtextColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: 1.0 - Math.abs(Tumbler.displacement) / (hourTumbler.visibleItemCount / 2)

                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 120 }
                        }
                    }

                    onCurrentIndexChanged: picker.emitDuration()
                }

                Text {
                    text: ":"
                    font.pixelSize: 48
                    font.bold: true
                    color: UiStyle.headerColor
                }

                Tumbler {
                    id: minuteTumbler
                    model: 60
                    wrap: true
                    visibleItemCount: 5
                    width: 120
                    height: 240

                    delegate: Text {
                        text: modelData < 10 ? "0" + modelData : modelData
                        font.pixelSize: minuteTumbler.currentIndex === index ? 40 : 24
                        font.bold: minuteTumbler.currentIndex === index
                        color: minuteTumbler.currentIndex === index ? UiStyle.textColor : UiStyle.subtextColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: 1.0 - Math.abs(Tumbler.displacement) / (minuteTumbler.visibleItemCount / 2)

                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 120 }
                        }
                    }

                    onCurrentIndexChanged: picker.emitDuration()
                }

                Text {
                    text: ":"
                    font.pixelSize: 48
                    font.bold: true
                    color: UiStyle.headerColor
                }

                Tumbler {
                    id: secondTumbler
                    model: 60
                    wrap: true
                    visibleItemCount: 5
                    width: 120
                    height: 240

                    delegate: Text {
                        text: modelData < 10 ? "0" + modelData : modelData
                        font.pixelSize: secondTumbler.currentIndex === index ? 40 : 24
                        font.bold: secondTumbler.currentIndex === index
                        color: secondTumbler.currentIndex === index ? UiStyle.textColor : UiStyle.subtextColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: 1.0 - Math.abs(Tumbler.displacement) / (secondTumbler.visibleItemCount / 2)

                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 120 }
                        }
                    }

                    onCurrentIndexChanged: picker.emitDuration()
                }
            }
        }
    }
}
