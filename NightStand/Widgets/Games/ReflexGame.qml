pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"
import "../Robot"
import "GameRules.js" as Rules

// Robot Refleks. Hedef rastgele bir gecikmeden sonra belirir; ölçülen şey
// belirme ile dokunuş arasındaki süre. Beş turun ortalaması skordur ve KÜÇÜK
// olan iyidir. Erken dokunma ceza puanı yazmaz, turu baştan başlatır: böylece
// ekrana sürekli vurarak iyi süre elde etmek mümkün değil.
GameShell {
    id: game

    gameId: "reflex"
    higherIsBetter: false
    usesTicker: false          // kare döngüsü gerekmiyor, FrameAnimation kapalı

    property int round: 0
    property int total: 0
    property bool armed: false          // hedef ekranda mı
    property real armedAt: 0
    property int lastMs: 0
    property bool tooEarly: false

    readonly property int roundsTotal: Rules.reflex.rounds

    function resetGame() {
        game.round = 0
        game.total = 0
        game.lastMs = 0
        game.tooEarly = false
        game.nextRound()
    }

    function nextRound() {
        game.armed = false
        game.tooEarly = false
        waitTimer.interval = Rules.randomBetween(Rules.reflex.minWait, Rules.reflex.maxWait)
        waitTimer.restart()
    }

    onStarted: game.resetGame()

    onTapped: {
        if (game.armed) {
            var ms = Math.round(Date.now() - game.armedAt)
            game.armed = false
            game.lastMs = ms
            game.total += ms
            game.round += 1
            if (game.round >= game.roundsTotal) {
                game.score = Math.round(game.total / game.roundsTotal)
                game.gameOver()
            } else {
                game.nextRound()
            }
        } else {
            // Hedef yokken dokunma: tur baştan
            waitTimer.stop()
            game.tooEarly = true
            earlyTimer.restart()
        }
    }

    Timer {
        id: waitTimer
        // running binding almıyor: kendini durduran timer'da binding bayatlar
        onTriggered: {
            game.armed = true
            game.armedAt = Date.now()
            popAnim.restart()
        }
    }

    Timer {
        id: earlyTimer
        interval: Rules.reflex.tooEarlyMs
        onTriggered: game.nextRound()
    }

    // --- sahne ---
    Item {
        anchors.fill: parent

        // Tur göstergesi
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            spacing: 10
            opacity: game.playing ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 200 } }

            Repeater {
                model: game.roundsTotal

                delegate: Rectangle {
                    required property int index

                    width: 12
                    height: 12
                    radius: 6
                    color: index < game.round ? UiStyle.buttonProgress : UiStyle.roundButtonColor
                    border.width: 1
                    border.color: UiStyle.subtextColor

                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }

        // Hedef halkası
        Item {
            id: target

            anchors.centerIn: parent
            width: 168
            height: 168
            opacity: game.armed ? 1 : 0
            visible: opacity > 0.01

            Behavior on opacity { NumberAnimation { duration: 90 } }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: UiStyle.buttonProgress
                opacity: 0.18
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.62
                height: width
                radius: width / 2
                color: UiStyle.buttonProgress
                opacity: 0.38
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.26
                height: width
                radius: width / 2
                color: UiStyle.buttonProgress
            }
        }

        SequentialAnimation {
            id: popAnim
            NumberAnimation { target: target; property: "scale"; from: 0.6; to: 1.0; duration: 140; easing.type: Easing.OutBack }
        }

        // Robot: hedefin altında, durumu ifadesiyle anlatır
        RobotCharacter {
            id: player

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 74
            faceSize: 92
            interactive: false
            animated: game.playing
            expression: game.phase === "over" ? "havali"
                        : game.tooEarly ? "kizgin"
                        : (game.armed ? "saskin" : "uykulu")
        }

        // Durum satırı: son süre ya da erken uyarısı
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: player.top
            anchors.bottomMargin: 18
            font.pixelSize: 26
            font.bold: true
            color: game.tooEarly ? UiStyle.red : UiStyle.textColor
            opacity: game.playing ? 1 : 0
            //: Çok erken!
            text: game.tooEarly ? qsTr("Too early!")
                  : (game.armed ? ""
                     : (game.lastMs > 0 ? game.lastMs + " ms" : ""))

            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }
}
