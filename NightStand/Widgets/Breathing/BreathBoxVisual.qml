import QtQuick
import "../../Style"

// "Odaklanma" modunun görseli: kutu nefesi.
//
// Karenin dört kenarı dört faza karşılık geliyor - al / tut / ver / tut. Aktif
// kenar `phaseProgress` ile accent rengine doluyor, üzerinde parlayan bir işaretçi
// çevre boyunca yürüyor. Döngü başında dolgular sıfırlanıyor. Kesikli nokta yok;
// Sakin modunun nokta halkasından bilerek tamamen farklı bir doku.
Item {
    id: root

    property real breathLevel: 0
    property string phaseKind: ""
    property real phaseProgress: 0
    property int phaseIndex: 0

    // Kenar sırası: 0 üst, 1 sağ, 2 alt, 3 sol.
    function fillOf(edge) {
        if (root.phaseIndex > edge)
            return 1
        if (root.phaseIndex === edge)
            return root.phaseProgress
        return 0
    }

    Item {
        id: box

        anchors.centerIn: parent
        width: Math.min(root.width, root.height) * 0.72
        height: width

        readonly property real thickness: Math.max(5, width * 0.022)
        readonly property color track: UiStyle.roundButtonColor
        readonly property color fill: UiStyle.headerColor

        // Nefesin kendisi: kare şişip iniyor
        scale: 0.88 + root.breathLevel * 0.18

        // Kareye hacim veren, nefesle güçlenen iç parıltı
        Rectangle {
            anchors.fill: parent
            anchors.margins: box.thickness
            radius: 22
            color: Qt.rgba(UiStyle.headerColor.r, UiStyle.headerColor.g,
                           UiStyle.headerColor.b, 0.05 + root.breathLevel * 0.13)
        }

        // --- Üst kenar: soldan sağa dolar ---
        Rectangle {
            x: 0; y: 0
            width: box.width; height: box.thickness
            radius: height / 2
            color: box.track

            Rectangle {
                width: parent.width * root.fillOf(0)
                height: parent.height
                radius: parent.radius
                color: box.fill
            }
        }

        // --- Sağ kenar: yukarıdan aşağıya dolar ---
        Rectangle {
            x: box.width - box.thickness; y: 0
            width: box.thickness; height: box.height
            radius: width / 2
            color: box.track

            Rectangle {
                width: parent.width
                height: parent.height * root.fillOf(1)
                radius: parent.radius
                color: box.fill
            }
        }

        // --- Alt kenar: sağdan sola dolar ---
        Rectangle {
            x: 0; y: box.height - box.thickness
            width: box.width; height: box.thickness
            radius: height / 2
            color: box.track

            Rectangle {
                anchors.right: parent.right
                width: parent.width * root.fillOf(2)
                height: parent.height
                radius: parent.radius
                color: box.fill
            }
        }

        // --- Sol kenar: aşağıdan yukarıya dolar ---
        Rectangle {
            x: 0; y: 0
            width: box.thickness; height: box.height
            radius: width / 2
            color: box.track

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * root.fillOf(3)
                radius: parent.radius
                color: box.fill
            }
        }

        // --- Çevrede yürüyen işaretçi ---
        //
        // Konum phaseIndex + phaseProgress'ten hesaplanıyor; x/y'ye Behavior
        // KONMUYOR, kaynak zaten faz animasyonuyla sürekli akıyor.
        Rectangle {
            id: marker

            readonly property real px: {
                var s = box.width
                switch (root.phaseIndex) {
                case 0: return root.phaseProgress * s
                case 1: return s
                case 2: return s - root.phaseProgress * s
                default: return 0
                }
            }
            readonly property real py: {
                var s = box.height
                switch (root.phaseIndex) {
                case 0: return 0
                case 1: return root.phaseProgress * s
                case 2: return s
                default: return s - root.phaseProgress * s
                }
            }

            width: box.thickness * 3.2
            height: width
            radius: width / 2
            antialiasing: true
            color: UiStyle.headerColor
            x: px - width / 2
            y: py - height / 2

            // Tut fazlarında bile hareket ölmesin diye nabız
            SequentialAnimation on opacity {
                running: root.visible
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.55; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.55; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.45
                height: width
                radius: width / 2
                antialiasing: true
                color: UiStyle.innerCardColor
            }
        }
    }
}
