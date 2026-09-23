pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"
import "../Robot"
import "GameRules.js" as Rules

// Robot Koşusu. Zemin sabit, robot yerinde koşar, dünya sola akar. Tek dokunuş
// zıplatır; havadayken ikinci zıplama yok. Hız zamanla artar, engeller üç
// nesnelik sabit havuzdan geri dönüştürülür.
//
// Engeller Repeater yerine ADLI üç öğe: Repeater.itemAt() tipsiz QQuickItem
// döndürdüğü için ox/oh gibi alanlar statik olarak çözülemiyordu.
GameShell {
    id: game

    gameId: "runner"
    higherIsBetter: true

    property real jumpY: 0           // zeminden yükseklik (px, yukarı pozitif)
    property real vy: 0
    property real scroll: 0
    property real elapsed: 0

    readonly property real groundY: height * Rules.runner.groundY
    readonly property real px: width * Rules.runner.playerX
    readonly property real playerSize: Math.max(52, Math.min(78, height * 0.12))
    readonly property real speed: Rules.runnerSpeed(game.elapsed)
    readonly property bool grounded: game.jumpY <= 0.5
    readonly property var obstaclePool: [obstacle0, obstacle1, obstacle2]

    component Obstacle: Rectangle {
        id: obstacleRoot

        property real ox: 0
        property real oh: 60
        property real ow: 32
        property real groundLine: 480

        x: obstacleRoot.ox
        y: obstacleRoot.groundLine - obstacleRoot.oh
        width: obstacleRoot.ow
        height: obstacleRoot.oh
        radius: 8
        color: UiStyle.headerColor
        opacity: 0.88

        // Tepe bandı: engelin yüksekliğini okunur kılar
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 5
            radius: 2.5
            color: UiStyle.buttonProgress
        }
    }

    function placeObstacle(obs, afterX) {
        obs.ox = afterX + Rules.runner.minGapPx + Math.random() * Rules.runner.gapJitter
        obs.oh = Rules.randomBetween(Rules.runner.minHeight, Rules.runner.maxHeight)
        obs.ow = Rules.randomBetween(Rules.runner.minWidth, Rules.runner.maxWidth)
    }

    function resetGame() {
        game.jumpY = 0
        game.vy = 0
        game.scroll = 0
        game.elapsed = 0
        var cursor = game.width + 60
        for (var i = 0; i < game.obstaclePool.length; i++) {
            game.placeObstacle(game.obstaclePool[i], cursor)
            cursor = game.obstaclePool[i].ox
        }
    }

    onStarted: game.resetGame()

    onTapped: {
        if (!game.grounded)
            return
        game.vy = Rules.runner.impulse
        dustAnim.restart()
    }

    onTick: (dt) => {
        game.elapsed += dt
        game.scroll += game.speed * dt
        game.score = Math.floor(game.scroll / Rules.runner.scoreDivisor)

        // Zıplama: yukarı pozitif, zemine oturunca sıfırlanır
        if (!game.grounded || game.vy > 0) {
            game.vy -= Rules.runner.gravity * dt
            game.jumpY += game.vy * dt
            if (game.jumpY <= 0) {
                game.jumpY = 0
                game.vy = 0
            }
        }

        var half = game.playerSize * Rules.runner.hitbox / 2
        var playerLeft = game.px - half
        var playerBottom = game.groundY - game.jumpY
        var playerTop = playerBottom - half * 2

        for (var i = 0; i < game.obstaclePool.length; i++) {
            var obs = game.obstaclePool[i]
            obs.ox -= game.speed * dt

            if (obs.ox + obs.ow < -40) {
                var furthest = 0
                for (var j = 0; j < game.obstaclePool.length; j++)
                    furthest = Math.max(furthest, game.obstaclePool[j].ox)
                game.placeObstacle(obs, furthest)
            }

            if (Rules.overlaps(playerLeft, playerTop, half * 2, half * 2,
                               obs.ox, game.groundY - obs.oh, obs.ow, obs.oh)) {
                shakeAnim.restart()
                game.gameOver()
                return
            }
        }
    }

    // --- sahne ---
    Item {
        id: sceneRoot

        anchors.fill: parent
        transform: Translate { id: shakeShift }

        GameScenery {
            scroll: game.scroll
            groundVisible: true
            groundY: game.groundY
            starCount: 26
        }

        Obstacle { id: obstacle0; groundLine: game.groundY }
        Obstacle { id: obstacle1; groundLine: game.groundY }
        Obstacle { id: obstacle2; groundLine: game.groundY }

        // Zıplama tozu: zeminde kısa bir halka
        Rectangle {
            id: dust

            width: 46
            height: 8
            radius: 4
            color: UiStyle.subtextColor
            opacity: 0
            x: game.px - width / 2
            y: game.groundY - height / 2
        }

        // Oyuncu
        RobotCharacter {
            id: player

            x: game.px - width / 2
            y: game.groundY - game.jumpY - height
            faceSize: game.playerSize
            interactive: false
            animated: game.playing
            mouthSegments: 9
            expression: game.phase === "over" ? "kizgin"
                                              : (game.grounded ? "mutlu" : "saskin")
            // Havadayken hafif geriye yatar
            rotation: Rules.clamp(-game.vy * 0.012, -10, 12)

            Behavior on rotation { NumberAnimation { duration: 110; easing.type: Easing.OutQuad } }
        }
    }

    ParallelAnimation {
        id: dustAnim
        NumberAnimation { target: dust; property: "opacity"; from: 0.5; to: 0; duration: 340 }
        NumberAnimation { target: dust; property: "scale"; from: 0.6; to: 1.6; duration: 340; easing.type: Easing.OutQuad }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: shakeShift; property: "x"; to: 12; duration: 45 }
        NumberAnimation { target: shakeShift; property: "x"; to: -9; duration: 60 }
        NumberAnimation { target: shakeShift; property: "x"; to: 0; duration: 90; easing.type: Easing.OutQuad }
    }
}
