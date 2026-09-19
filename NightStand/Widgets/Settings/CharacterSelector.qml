pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"
import "../../Widgets/Robot"

// Robot karakteri seçici. ClockStylePicker sözleşmesi: durumsuz — seçili değer dışarıdan
// gelir, tıklama yalnızca sinyal yayar, yazma sorumluluğu ebeveyndedir.
// Önizlemeler gerçek karakter bileşenleridir ama animated:false ile donmuştur.
Item {
    id: picker

    property string selectedId: "classic"

    signal characterSelected(string id)

    readonly property var characters: [
        { id: "classic", label: qsTr("Klasik Robot") },
        { id: "eve", label: qsTr("EVE") }
    ]

    readonly property real cardHeight: 132
    readonly property real cardSpacing: 10

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: picker.cardSpacing

        Repeater {
            model: picker.characters

            delegate: Item {
                id: card

                required property var modelData
                readonly property bool selected: picker.selectedId === modelData.id

                width: parent.width
                height: picker.cardHeight
                scale: pressArea.pressed ? 0.97 : 1.0

                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: card.selected ? UiStyle.innerCardColor : UiStyle.transparent
                    border.width: card.selected ? 2 : 1
                    border.color: card.selected ? UiStyle.headerColor : UiStyle.roundButtonColor

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 14

                    // Donmuş canlı önizleme: gerçek bileşenin kendisi
                    Item {
                        width: 84
                        height: 108
                        anchors.verticalCenter: parent.verticalCenter

                        RobotCharacter {
                            anchors.centerIn: parent
                            character: card.modelData.id
                            expression: "mutlu"
                            animated: false
                            interactive: false
                            faceSize: 78
                            mouthSegments: 9
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: card.modelData.label
                            font.pixelSize: 15
                            font.bold: card.selected
                            color: card.selected ? UiStyle.headerColor : UiStyle.textColor

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Text {
                            text: card.selected ? qsTr("Seçili") : qsTr("Seçmek için dokun")
                            font.pixelSize: 11
                            color: UiStyle.subtextColor
                        }
                    }
                }

                MouseArea {
                    id: pressArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: picker.characterSelected(card.modelData.id)
                }
            }
        }
    }
}
