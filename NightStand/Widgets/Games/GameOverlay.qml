pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"

// Tam ekran oyun kabı. Nefes egzersizindeki sözleşmenin aynısı: Main.qml'de
// header'dan SONRA gelen bir kardeş, z: 1100, opak zemin. Sayfa içine konsaydı
// üst bar onu örterdi - StackView base'i header'dan önce tanımlı.
//
// Loader aktif oyunu yükler; appController.activeGame boşalınca öğe yok edilir,
// böylece kare döngüsü ve tüm timer'lar kesin olarak durur.
Rectangle {
    id: root

    readonly property string activeGame: appController.activeGame
    readonly property bool active: root.activeGame !== ""

    anchors.fill: parent
    color: UiStyle.baseColor
    visible: opacity > 0 || root.active
    opacity: root.active ? 1.0 : 0.0
    z: 1100

    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    // Alttaki sayfaya dokunuş sızmasın
    MouseArea {
        anchors.fill: parent
        enabled: root.active
    }

    Loader {
        id: gameLoader

        anchors.fill: parent
        active: root.active
        sourceComponent: {
            switch (root.activeGame) {
            case "flappy": return flappyComponent
            case "runner": return runnerComponent
            case "reflex": return reflexComponent
            }
            return null
        }
    }

    Component {
        id: flappyComponent

        FlappyGame {
            active: root.active
            onExitRequested: appController.stopGame()
        }
    }

    Component {
        id: runnerComponent

        RunnerGame {
            active: root.active
            onExitRequested: appController.stopGame()
        }
    }

    Component {
        id: reflexComponent

        ReflexGame {
            active: root.active
            onExitRequested: appController.stopGame()
        }
    }
}
