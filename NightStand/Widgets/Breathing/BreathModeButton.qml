import QtQuick
import "../../Style"

// Nefes overlay'inin sol sütunundaki mod seçim butonu.
//
// Dar ve ortalanmış: içinde yalnızca modun adı var. Stil sözleşmesi ActionCard.qml
// ile aynı (radius 16, 2px accent kenarlık, basma küçültmesi); seçili durum ayrıca
// zemini accent'in düşük alfalı tonuna çekiyor.
Rectangle {
    id: root

    property string label: ""
    property bool selected: false

    signal clicked()

    radius: 16
    color: selected ? Qt.rgba(UiStyle.headerColor.r, UiStyle.headerColor.g,
                              UiStyle.headerColor.b, 0.18)
                    : UiStyle.innerCardColor
    border.width: 2
    border.color: (selected || pressArea.containsMouse) ? UiStyle.headerColor
                                                        : UiStyle.transparent

    // Seçili büyütmesi ile basma küçültmesi çarpılarak birleşiyor (AmbianceOverlay
    // swatch'larındaki disiplinin aynısı).
    scale: (pressArea.pressed ? 0.96 : 1.0) * (selected ? 1.03 : 1.0)
    opacity: pressArea.pressed ? 0.9 : 1.0

    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Text {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        text: root.label
        font.pixelSize: 19
        font.bold: true
        color: UiStyle.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // MouseArea bilerek en sonda: metnin üstünde kalsın (TodoPreviewCard deseni).
    MouseArea {
        id: pressArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
