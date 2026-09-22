import QtQuick
import "../../Style"

// "Sakin" modunun görseli: çembere dizilmiş noktalar.
//
// Tek sürücü `breathLevel`. Nefes alırken 0 -> 1 aktığı için noktalar saat yönünde
// TEK TEK şişip parlıyor; nefes verirken 1 -> 0 indiği için aynı noktalar TERS
// sırada tek tek sönüyor. Nokta başına ayrı animasyon yok - "tek tek" hissi
// tamamen her noktanın kendi Behavior'ından geliyor.
Item {
    id: root

    property real breathLevel: 0
    property string phaseKind: ""
    property real phaseProgress: 0

    readonly property int dotCount: 12
    readonly property real radius: Math.min(width, height) / 2
    readonly property real ringRadius: radius * 0.78
    readonly property real dotSize: Math.max(8, radius * 0.1)

    // Merkezdeki yumuşak nefes dairesi
    Rectangle {
        id: core

        anchors.centerIn: parent
        width: root.radius * 0.92
        height: width
        radius: width / 2
        antialiasing: true
        color: Qt.rgba(UiStyle.headerColor.r, UiStyle.headerColor.g,
                       UiStyle.headerColor.b, 0.12 + root.breathLevel * 0.16)
        border.width: 2
        border.color: Qt.rgba(UiStyle.headerColor.r, UiStyle.headerColor.g,
                              UiStyle.headerColor.b, 0.25 + root.breathLevel * 0.45)

        scale: 0.75 + root.breathLevel * 0.25
    }

    Repeater {
        model: root.dotCount

        delegate: Rectangle {
            id: dot

            required property int index

            // Saat 12'den başlayıp saat yönünde ilerleyen trigonometrik yerleşim
            // (AnalogClock.qml'deki rakam dizilimiyle aynı formül).
            readonly property real angle: index * (2 * Math.PI / root.dotCount)
            readonly property bool lit: index < root.breathLevel * root.dotCount

            width: root.dotSize
            height: root.dotSize
            radius: width / 2
            antialiasing: true
            color: UiStyle.headerColor

            x: root.width / 2 + Math.sin(angle) * root.ringRadius - width / 2
            y: root.height / 2 - Math.cos(angle) * root.ringRadius - height / 2

            scale: lit ? 1.9 : 1.0
            opacity: lit ? 1.0 : 0.22

            Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutQuad } }
        }
    }
}
