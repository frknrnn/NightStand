pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"
import "../Robot"
import "GameRules.js" as Rules

// Robot Uçuşu. Oyuncu ekranın solunda sabit x'te durur, yerçekimi onu aşağı
// çeker, her dokunuş yukarı bir impuls verir. Kapılar sağdan sola akar ve
// ekranın solundan çıkınca sağa geri dönüştürülür - üç kapılık sabit havuz,
// oyun boyunca tek bir nesne bile yaratılmaz.
//
// Kapılar Repeater yerine ADLI üç öğe: Repeater.itemAt() geriye tipsiz bir
// QQuickItem verdiği için gx/gapY gibi özel alanlar statik olarak çözülemiyordu.
GameShell {
    id: game

    gameId: "flappy"
    higherIsBetter: true

    // --- oynanış durumu (piksel / saniye) ---
    property real py: height * 0.42
    property real vy: 0
    property real scroll: 0

    readonly property real px: width * Rules.flappy.playerX
    readonly property real playerSize: Math.max(52, Math.min(74, height * 0.11))
    readonly property real speed: Rules.flappySpeed(game.score)
    readonly property real gap: Rules.flappyGap(game.score)
    readonly property var gatePool: [gate0, gate1, gate2]

    // Kapı: sahne yüksekliği ve boşluk dışarıdan geçilir, çünkü satır içi
    // bileşen dış kapsamdaki id'leri göremez.
    component Gate: Item {
        id: gateRoot

        property real gx: 0
        property real gapY: 0
        property bool scored: false
        property real gap: 200
        property real sceneHeight: 600
        property real gateWidth: 66

        x: gateRoot.gx
        width: gateRoot.gateWidth
        height: gateRoot.sceneHeight

        // Üst blok
        Rectangle {
            width: parent.width
            height: Math.max(0, gateRoot.gapY - gateRoot.gap / 2)
            radius: 14
            color: UiStyle.headerColor
            opacity: 0.85

            // Ağız bandı: boşluğun nerede bittiğini okunur kılar
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 8
                radius: 4
                color: UiStyle.buttonProgress
            }
        }

        // Alt blok
        Rectangle {
            y: gateRoot.gapY + gateRoot.gap / 2
            width: parent.width
            height: Math.max(0, gateRoot.sceneHeight - y)
            radius: 14
            color: UiStyle.headerColor
            opacity: 0.85

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 8
                radius: 4
                color: UiStyle.buttonProgress
            }
        }
    }

    function randomGapY() {
        var margin = game.gap / 2 + 40
        return Rules.randomBetween(margin, game.height - margin)
    }

    function resetGame() {
        game.py = game.height * 0.42
        game.vy = 0
        game.scroll = 0
        for (var i = 0; i < game.gatePool.length; i++) {
            var gate = game.gatePool[i]
            gate.gx = game.width + 140 + i * Rules.flappy.gateSpacing
            gate.gapY = game.randomGapY()
            gate.scored = false
        }
    }

    function crash() {
        shakeAnim.restart()
        game.gameOver()
    }

    onStarted: game.resetGame()

    onTapped: {
        game.vy = -Rules.flappy.impulse
        flapAnim.restart()
    }

    onTick: (dt) => {
        // Dikey hareket
        game.vy = Math.min(Rules.flappy.maxFall, game.vy + Rules.flappy.gravity * dt)
        game.py += game.vy * dt
        game.scroll += game.speed * dt

        var half = game.playerSize * Rules.flappy.hitbox / 2

        // Tavan ve zemin
        if (game.py - half < 0 || game.py + half > game.height) {
            game.py = Rules.clamp(game.py, half, game.height - half)
            game.crash()
            return
        }

        for (var i = 0; i < game.gatePool.length; i++) {
            var gate = game.gatePool[i]
            gate.gx -= game.speed * dt

            // Geri dönüştürme: en sağdaki kapının arkasına eklenir
            if (gate.gx + Rules.flappy.gateWidth < -20) {
                var furthest = 0
                for (var j = 0; j < game.gatePool.length; j++)
                    furthest = Math.max(furthest, game.gatePool[j].gx)
                gate.gx = furthest + Rules.flappy.gateSpacing
                gate.gapY = game.randomGapY()
                gate.scored = false
            }

            // Puan: kapı oyuncuyu geçtiği anda
            if (!gate.scored && gate.gx + Rules.flappy.gateWidth < game.px - half) {
                gate.scored = true
                game.score = game.score + 1
            }

            // Çarpışma: kapı sütunuyla çakışma varsa boşluğun içinde miyiz
            if (Rules.overlaps(game.px - half, game.py - half, half * 2, half * 2,
                               gate.gx, 0, Rules.flappy.gateWidth, game.height)) {
                var gapTop = gate.gapY - game.gap / 2
                var gapBottom = gate.gapY + game.gap / 2
                if (game.py - half < gapTop || game.py + half > gapBottom) {
                    game.crash()
                    return
                }
            }
        }
    }

    // --- sahne ---
    // Her şey tek Item içinde: çarpma sarsıntısı buna uygulanıyor, kök öğe
    // anchors.fill kullandığı için orada x animasyonu işe yaramazdı.
    Item {
        id: sceneRoot

        anchors.fill: parent
        transform: Translate { id: shakeShift }

        GameScenery {
            scroll: game.scroll
            starCount: 34
        }

        Gate {
            id: gate0
            gap: game.gap
            sceneHeight: game.height
            gateWidth: Rules.flappy.gateWidth
        }

        Gate {
            id: gate1
            gap: game.gap
            sceneHeight: game.height
            gateWidth: Rules.flappy.gateWidth
        }

        Gate {
            id: gate2
            gap: game.gap
            sceneHeight: game.height
            gateWidth: Rules.flappy.gateWidth
        }

        // Oyuncu: seçili robot karakteri
        RobotCharacter {
            id: player

            x: game.px - width / 2
            y: game.py - height / 2
            faceSize: game.playerSize
            interactive: false
            animated: game.playing
            mouthSegments: 9
            expression: game.phase === "over" ? "kizgin"
                                              : (game.vy < -60 ? "saskin" : "mutlu")

            // Hıza göre eğilme: yukarı çıkarken burun yukarı, düşerken aşağı
            rotation: Rules.clamp(game.vy * 0.06, Rules.flappy.tiltUp, Rules.flappy.tiltDown)

            Behavior on rotation { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
        }
    }

    // Kanat çırpma: küçük bir ölçek vuruşu
    SequentialAnimation {
        id: flapAnim
        NumberAnimation { target: player; property: "scale"; to: 1.12; duration: 80; easing.type: Easing.OutQuad }
        NumberAnimation { target: player; property: "scale"; to: 1.00; duration: 170; easing.type: Easing.OutBack }
    }

    // Çarpma sarsıntısı: sessiz oyunda geri bildirimi bu taşıyor
    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: shakeShift; property: "x"; to: 12; duration: 45 }
        NumberAnimation { target: shakeShift; property: "x"; to: -9; duration: 60 }
        NumberAnimation { target: shakeShift; property: "x"; to: 0; duration: 90; easing.type: Easing.OutQuad }
    }
}
