import QtQuick
import "../../Style"

// "Rahatlama" modunun görseli: açılıp kapanan çiçek.
//
// Nefes alırken yapraklar merkezden dışarı uzayıp parlıyor, verirken kapanıyor.
// Kesikli hiçbir öğe yok - Sakin'in nokta halkasından ve Odaklanma'nın kutusundan
// tamamen farklı, sürekli bir doku.
//
// Bekleme (tut) fazlarında gövde sonsuz yavaş dönüşüne devam ederken bir de
// sin eğrisiyle parlayıp sönüyor: eğri 0'da başlayıp 0'da bittiği için faz
// değişiminde hiçbir sıçrama olmuyor.
Item {
    id: root

    property real breathLevel: 0
    property string phaseKind: ""
    property real phaseProgress: 0

    readonly property bool holding: phaseKind === "holdIn" || phaseKind === "holdOut"
    readonly property real shimmer: holding ? Math.sin(phaseProgress * Math.PI) * 0.28 : 0

    // Arkadaki yumuşak parıltı
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(root.width, root.height) * 0.9
        height: width
        radius: width / 2
        antialiasing: true
        color: Qt.rgba(UiStyle.headerColor.r, UiStyle.headerColor.g, UiStyle.headerColor.b,
                       0.05 + root.breathLevel * 0.12 + root.shimmer * 0.06)
        scale: 0.6 + root.breathLevel * 0.4
    }

    Item {
        id: bloom

        anchors.centerIn: parent
        width: Math.min(root.width, root.height)
        height: width

        readonly property real pr: width / 2

        // Çok yavaş, sonsuz dönüş. Sonsuz döngüde `running` bağlamak güvenli.
        NumberAnimation on rotation {
            running: root.visible
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 90000
        }

        // Dış taç yaprakları
        Repeater {
            model: 6

            delegate: Item {
                required property int index

                anchors.fill: parent
                rotation: index * 60

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: bloom.pr * 0.17
                    height: bloom.pr * (0.22 + root.breathLevel * 0.34)
                    y: bloom.pr - bloom.pr * (0.10 + root.breathLevel * 0.30) - height
                    radius: width / 2
                    antialiasing: true
                    color: UiStyle.headerColor
                    opacity: 0.32 + root.breathLevel * 0.55 + root.shimmer * 0.4
                }
            }
        }

        // İç taç yaprakları - 30 derece kaydırılmış, daha kısa
        Repeater {
            model: 6

            delegate: Item {
                required property int index

                anchors.fill: parent
                rotation: index * 60 + 30

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: bloom.pr * 0.12
                    height: bloom.pr * (0.14 + root.breathLevel * 0.22)
                    y: bloom.pr - bloom.pr * (0.07 + root.breathLevel * 0.19) - height
                    radius: width / 2
                    antialiasing: true
                    color: UiStyle.headerColor
                    opacity: 0.2 + root.breathLevel * 0.4 + root.shimmer * 0.3
                }
            }
        }
    }

    // Merkezdeki çekirdek
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(root.width, root.height) * 0.14
        height: width
        radius: width / 2
        antialiasing: true
        color: UiStyle.headerColor
        opacity: 0.35 + root.breathLevel * 0.45
        scale: 0.8 + root.breathLevel * 0.35
    }
}
