pragma ComponentBehavior: Bound

import QtQuick
import "../../AppSettings"

// Seçili karakteri yükleyen ince sarmalayıcı. RobotFace / EveFace ile aynı genel API'yi
// sunar, böylece sayfa ve ifade butonları hangi karakterin çizildiğini bilmek zorunda kalmaz.
// Karakter varsayılan olarak ayardan gelir: tek noktadan beslenir, mini ikonlar da takip eder.
Item {
    id: root

    property string character: UiSettings.robotCharacter   // "classic" | "eve"
    property string expression: "mutlu"
    property bool animated: true
    property bool interactive: false
    property real faceSize: 200
    property int mouthSegments: 15

    signal tapped()

    // İki karakter de aynı 118u x 130u ızgarayı kullanır (u = faceSize / 100)
    implicitWidth: faceSize * 1.18
    implicitHeight: faceSize * 1.30

    // Yüklü karaktere tip güvenli ulaşım: Loader.item QObject olduğu için
    // istekler sinyalle iletilir, içerideki Connections doğrudan çağırır.
    signal reactRequested()
    signal blinkRequested()

    function react() {
        root.reactRequested()
    }

    function blink() {
        root.blinkRequested()
    }

    Loader {
        id: loader
        anchors.centerIn: parent
        sourceComponent: root.character === "eve" ? eveComponent : classicComponent
    }

    Component {
        id: classicComponent

        RobotFace {
            id: classicFace

            expression: root.expression
            animated: root.animated
            interactive: root.interactive
            faceSize: root.faceSize
            mouthSegments: root.mouthSegments
            onTapped: root.tapped()

            Connections {
                target: root
                function onReactRequested() { classicFace.react() }
                function onBlinkRequested() { classicFace.blink() }
            }
        }
    }

    Component {
        id: eveComponent

        EveFace {
            id: eveFace

            expression: root.expression
            animated: root.animated
            interactive: root.interactive
            faceSize: root.faceSize
            mouthSegments: root.mouthSegments
            onTapped: root.tapped()

            Connections {
                target: root
                function onReactRequested() { eveFace.react() }
                function onBlinkRequested() { eveFace.blink() }
            }
        }
    }
}
