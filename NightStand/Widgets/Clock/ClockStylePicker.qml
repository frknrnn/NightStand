import QtQuick
import "../../Style"
import "../../Widgets/Clock"
import "../Common"

// Kapalıyken yalnızca o anki seçimi gösteren kart; dokununca stil listesi açılır,
// bir stil seçilince kendiliğinden kapanır.
//
// State'i BU bileşen sahiplenmiyor - `expanded` salt girdi, ClockView sürüyor.
// Böylece iki expander aynı anda açılamıyor ve binding döngüsü oluşmuyor.
Item {
    id: picker

    // "analog" → kadran stilleri, "digital" → dijital saat stilleri
    property string mode: "analog"
    property int selectedIndex: 0
    // Bu kolon şu an ekrandaki saati sürüyor mu
    property bool isActiveMode: false
    property bool expanded: false

    signal styleSelected(int index)
    signal toggleRequested()

    readonly property bool analogMode: mode === "analog"
    readonly property var labels: analogMode
                                  ? [qsTr("Klasik"), qsTr("Sade"), qsTr("Rakam"), qsTr("Neon"), qsTr("Nokta")]
                                  : [qsTr("Klasik"), qsTr("Sade"), qsTr("Mono"), qsTr("LCD"), qsTr("12s")]

    // Önizlemeler sabit bir saatte durur; saniyede bir yeniden çizim olmaz
    readonly property date previewTime: new Date(2000, 0, 1, 10, 10, 30)

    // --- Geometri (hepsi kolon yüksekliğinden türetilir) -------------------
    readonly property real itemHeight: 66
    readonly property real itemSpacing: 6
    readonly property real panelPadding: 8
    readonly property real collapsedHeight: 96
    readonly property real expandedHeight: 5 * itemHeight + 4 * itemSpacing + 2 * panelPadding

    readonly property real collapsedY: (height - collapsedHeight) / 2

    // Seçili öğenin merkezi, kapalı kartın merkeziyle çakışsın; kolona sığmazsa yaslanır
    readonly property real idealY: height / 2
                                 - (panelPadding + selectedIndex * (itemHeight + itemSpacing) + itemHeight / 2)
    readonly property real expandedY: Math.max(0, Math.min(height - expandedHeight, idealY))

    // Açıkken dokunulmazsa kendi kapanır.
    //
    // `running` bilerek binding almıyor: repeat'siz bir Timer tetiklendiğinde
    // running'i kendisi false'a çekiyor, bu da `running: expanded` bindingini
    // bayatlatıyor. ExpressionDrawer.qml'deki gibi imperative sürülüyor.
    Timer {
        id: autoCollapse
        interval: 4000
        onTriggered: picker.toggleRequested()
    }

    onExpandedChanged: {
        if (expanded)
            autoCollapse.restart()
        else
            autoCollapse.stop()
    }

    // Kapalı kart ve açık liste tek panel; y ve height animasyonla değişir
    Rectangle {
        id: panel

        width: parent.width
        y: picker.expanded ? picker.expandedY : picker.collapsedY
        height: picker.expanded ? picker.expandedHeight : picker.collapsedHeight
        radius: 20
        color: UiStyle.cardPanelColor
        border.width: picker.isActiveMode ? 2 : 1
        border.color: picker.isActiveMode ? UiStyle.headerColor : UiStyle.roundButtonColor

        // Kapanma animasyonu sırasında liste kartın dışına taşmasın
        clip: true

        Behavior on y {
            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }
        Behavior on height {
            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }
        Behavior on border.color { ColorAnimation { duration: 200 } }
        Behavior on color { ColorAnimation { duration: 250 } }

        // ---- A. Kapalı içerik: o anki seçim ----
        Item {
            id: collapsedContent

            width: parent.width
            height: picker.collapsedHeight
            opacity: picker.expanded ? 0.0 : 1.0
            visible: opacity > 0
            enabled: !picker.expanded
            scale: collapsedArea.pressed ? 0.96 : 1.0

            Behavior on opacity { NumberAnimation { duration: 180 } }
            Behavior on scale {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Column {
                anchors.centerIn: parent
                spacing: 2

                Item {
                    width: 76
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    Loader {
                        anchors.centerIn: parent
                        active: picker.analogMode
                        sourceComponent: AnalogClock {
                            diameter: 48
                            styleIndex: picker.selectedIndex
                            digitalStyleIndex: -1
                            compact: true
                            now: picker.previewTime
                        }
                    }

                    Loader {
                        anchors.centerIn: parent
                        active: !picker.analogMode
                        sourceComponent: DigitalClock {
                            styleIndex: picker.selectedIndex
                            baseFontSize: 15
                            compact: true
                            now: picker.previewTime
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: picker.labels[picker.selectedIndex]
                    font.pixelSize: 11
                    font.bold: true
                    color: picker.isActiveMode ? UiStyle.headerColor : UiStyle.subtextColor

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                ThemedIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    // chevron-right döndürülerek aşağı/yukarı oka çevrilir
                    source: UiStyle.monoIconPath("chevron-right")
                    size: 16
                    color: UiStyle.subtextColor
                    rotation: picker.expanded ? -90 : 90
                    opacity: collapsedArea.pressed ? 1.0 : 0.7

                    Behavior on rotation {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }

            MouseArea {
                id: collapsedArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: picker.toggleRequested()
            }
        }

        // ---- B. Açık liste: 5 stil ----
        Column {
            id: styleList

            anchors.fill: parent
            anchors.margins: picker.panelPadding
            spacing: picker.itemSpacing

            opacity: picker.expanded ? 1.0 : 0.0
            visible: opacity > 0
            enabled: picker.expanded

            Behavior on opacity { NumberAnimation { duration: 180 } }

            Repeater {
                model: 5

                Item {
                    id: styleItem

                    readonly property int styleIdx: index
                    readonly property bool selected: picker.selectedIndex === styleIdx

                    width: styleList.width
                    height: picker.itemHeight
                    scale: itemArea.pressed ? 0.94 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: styleItem.selected ? UiStyle.innerCardColor : UiStyle.transparent
                        border.width: styleItem.selected ? 2 : 1
                        border.color: styleItem.selected
                                      ? UiStyle.headerColor
                                      : UiStyle.roundButtonColor
                        opacity: styleItem.selected ? 1.0 : 0.45

                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Item {
                            width: 72
                            height: 42
                            anchors.horizontalCenter: parent.horizontalCenter

                            Loader {
                                anchors.centerIn: parent
                                active: picker.analogMode
                                sourceComponent: AnalogClock {
                                    diameter: 42
                                    styleIndex: styleItem.styleIdx
                                    digitalStyleIndex: -1
                                    compact: true
                                    now: picker.previewTime
                                }
                            }

                            Loader {
                                anchors.centerIn: parent
                                active: !picker.analogMode
                                sourceComponent: DigitalClock {
                                    styleIndex: styleItem.styleIdx
                                    baseFontSize: 14
                                    compact: true
                                    now: picker.previewTime
                                }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: picker.labels[styleItem.styleIdx]
                            font.pixelSize: 10
                            font.bold: styleItem.selected
                            color: styleItem.selected ? UiStyle.headerColor : UiStyle.subtextColor

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: autoCollapse.restart()
                        onClicked: picker.styleSelected(styleItem.styleIdx)
                    }
                }
            }
        }
    }
}
