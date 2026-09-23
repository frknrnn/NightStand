pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"

// Oyunların paylaştığı arka plan: paralaks yıldız katmanları ve isteğe bağlı
// zemin çizgisi. Kaydırma değerini oyun verir (scroll, px); burada yalnızca
// modulo ile sarma yapılır, kendi başına hiçbir animasyon çalışmaz - böylece
// oyun durduğunda arka plan da durur.
Item {
    id: scenery

    property real scroll: 0
    property bool groundVisible: false
    property real groundY: height * 0.8
    property int starCount: 30

    anchors.fill: parent

    // Uzak yıldızlar: yavaş katman
    Repeater {
        model: scenery.starCount

        delegate: Rectangle {
            required property int index

            // Sahte rastgelelik: index tabanlı, her açılışta aynı gökyüzü
            readonly property real seedX: (index * 137.51) % 1.0
            readonly property real seedY: (index * 71.13) % 1.0
            readonly property real depth: 0.25 + ((index * 53.7) % 1.0) * 0.55
            readonly property real span: scenery.width + 40

            width: 2 + (index % 3)
            height: width
            radius: width / 2
            color: UiStyle.textColor
            opacity: 0.10 + depth * 0.22

            // Derin katman daha yavaş kayar
            x: {
                var raw = seedX * span - scenery.scroll * depth * 0.35
                var wrapped = raw % span
                return wrapped < -20 ? wrapped + span : wrapped
            }
            y: seedY * (scenery.groundVisible ? scenery.groundY - 30 : scenery.height * 0.85)
        }
    }

    // Zemin: yalnız koşu oyununda
    Rectangle {
        visible: scenery.groundVisible
        anchors.left: parent.left
        anchors.right: parent.right
        y: scenery.groundY
        height: 2
        color: UiStyle.subtextColor
        opacity: 0.55
    }

    // Zemin dokusu: kayan kısa çizgiler, hız hissini veren asıl şey
    Repeater {
        model: scenery.groundVisible ? 14 : 0

        delegate: Rectangle {
            required property int index

            readonly property real span: scenery.width + 120

            width: 26 + (index % 4) * 14
            height: 2
            radius: 1
            color: UiStyle.subtextColor
            opacity: 0.28

            x: {
                var raw = index * 86 - scenery.scroll
                var wrapped = raw % span
                return wrapped < -120 ? wrapped + span : wrapped
            }
            y: scenery.groundY + 12 + (index % 3) * 9
        }
    }

    // Zemin altı gölgesi: sahneyi oturtur
    Rectangle {
        visible: scenery.groundVisible
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        y: scenery.groundY
        height: parent.height - scenery.groundY
        color: UiStyle.headerColor
        opacity: 0.04
    }
}
