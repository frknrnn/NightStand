pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"

// Arayüz dili seçici. CharacterSelector sözleşmesi: durumsuz — seçili değer
// dışarıdan gelir, tıklama yalnızca sinyal yayar, yazma sorumluluğu ebeveyndedir.
//
// Etiketler bilerek qsTr() ile sarmalanmıyor: dil seçici, o an aktif olan dili
// OKUYAMAYAN kullanıcının okuyabilmesi gereken tek kontroldür. "Türkçe" çevrilseydi
// İngilizce arayüzde "Turkish" yazardı - tam da ihtiyacı olan kişiye faydasız.
// Bu yüzden yerel adlar C++ tarafından düz dizge olarak veriliyor.
Item {
    id: picker

    property string selectedCode: "en"

    signal languageSelected(string code)

    readonly property real cardHeight: 56
    readonly property real cardSpacing: 10

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: picker.cardSpacing

        Repeater {
            model: languageManager.availableLanguages

            delegate: Item {
                id: card

                required property var modelData
                readonly property bool selected: picker.selectedCode === modelData.code

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

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    text: card.modelData.label
                    font.pixelSize: 15
                    font.bold: card.selected
                    color: card.selected ? UiStyle.headerColor : UiStyle.textColor

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    text: "✓"
                    font.pixelSize: 16
                    font.bold: true
                    color: UiStyle.headerColor
                    visible: card.selected
                }

                MouseArea {
                    id: pressArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: picker.languageSelected(card.modelData.code)
                }
            }
        }
    }
}
