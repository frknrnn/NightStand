import QtQuick
import "../../Style"
import "../../Widgets/Clock"

Rectangle {
    id: picker

    // "analog" → kadran stilleri, "digital" → dijital saat stilleri
    property string mode: "analog"
    property int selectedIndex: 0
    // Bu kolon şu an ekrandaki saati sürüyor mu
    property bool isActiveMode: false

    signal styleSelected(int index)

    readonly property bool analogMode: mode === "analog"
    readonly property var labels: analogMode
                                  ? [qsTr("Klasik"), qsTr("Sade"), qsTr("Rakam"), qsTr("Neon"), qsTr("Nokta")]
                                  : [qsTr("Klasik"), qsTr("Sade"), qsTr("Mono"), qsTr("LCD"), qsTr("12s")]

    // Önizlemeler sabit bir saatte durur; saniyede bir yeniden çizim olmaz
    readonly property date previewTime: new Date(2000, 0, 1, 10, 10, 30)

    readonly property real buttonHeight: 84
    readonly property real buttonSpacing: 8

    radius: 18
    color: UiStyle.cardPanelColor

    Behavior on color { ColorAnimation { duration: 250 } }

    Item {
        id: strip

        anchors.centerIn: parent
        width: parent.width - 12
        height: 5 * picker.buttonHeight + 4 * picker.buttonSpacing

        // Kayan seçim göstergesi
        Rectangle {
            width: strip.width
            height: picker.buttonHeight
            radius: 14
            color: UiStyle.innerCardColor
            opacity: picker.isActiveMode ? 1.0 : 0.25
            y: picker.selectedIndex * (picker.buttonHeight + picker.buttonSpacing)

            Behavior on y {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 220 }
            }
        }

        Column {
            anchors.fill: parent
            spacing: picker.buttonSpacing

            Repeater {
                model: 5

                Item {
                    id: styleButton

                    readonly property int styleIdx: index
                    readonly property bool selected: picker.selectedIndex === styleIdx

                    width: strip.width
                    height: picker.buttonHeight
                    scale: pressArea.pressed ? 0.94 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: UiStyle.transparent
                        border.width: styleButton.selected ? 2 : 1
                        border.color: styleButton.selected && picker.isActiveMode
                                      ? UiStyle.headerColor
                                      : UiStyle.roundButtonColor
                        opacity: styleButton.selected ? 1.0 : 0.45

                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Item {
                            // 12 saat stilinin AM/PM rozeti 52px'e sığmadığı için
                            // önizleme kutusu buton genişliğine yakın tutulur
                            width: 76
                            height: 52
                            anchors.horizontalCenter: parent.horizontalCenter

                            Loader {
                                anchors.centerIn: parent
                                active: picker.analogMode
                                sourceComponent: AnalogClock {
                                    diameter: 50
                                    styleIndex: styleButton.styleIdx
                                    digitalStyleIndex: -1
                                    compact: true
                                    now: picker.previewTime
                                }
                            }

                            Loader {
                                anchors.centerIn: parent
                                active: !picker.analogMode
                                sourceComponent: DigitalClock {
                                    styleIndex: styleButton.styleIdx
                                    baseFontSize: 15
                                    compact: true
                                    now: picker.previewTime
                                }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: picker.labels[styleButton.styleIdx]
                            font.pixelSize: 11
                            font.bold: styleButton.selected
                            color: styleButton.selected && picker.isActiveMode
                                   ? UiStyle.headerColor
                                   : UiStyle.subtextColor

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    MouseArea {
                        id: pressArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: picker.styleSelected(styleButton.styleIdx)
                    }
                }
            }
        }
    }
}
