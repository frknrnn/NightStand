import QtQuick
import "../../AppSettings"
import "../../Style"
import "../../Strings"
import "../Clock"

// Üç oyunun ortak çerçevesi: 3-2-1 geri sayım, kare döngüsü, HUD, rekor
// kalıcılığı ve oyun sonu kartı. Oyunlar bu bileşeni KÖK olarak kullanır ve
// yalnızca kendi sahnelerini içine koyar (default property alias).
//
// Sözleşme: sahne oynanışı yürütür, skoru score'a yazar ve bitince gameOver()
// çağırır. Çerçeve durumu, kaydı ve arayüzü üstlenir.
Item {
    id: shell

    property string gameId: ""
    // Overlay görünür mü: false olunca döngü durur, hiçbir timer kalmaz
    property bool active: true
    property int score: 0
    // Refleks oyununda küçük olan iyidir (ms)
    property bool higherIsBetter: true
    // Kare döngüsüne ihtiyacı olmayan oyun (refleks) bunu kapatır
    property bool usesTicker: true
    // Oyuncunun ilk dokunuşuna kadar gösterilen ipucu
    property bool hintVisible: true

    property string phase: "countdown"       // countdown | playing | over
    readonly property bool playing: phase === "playing"

    property int best: 0
    property bool newRecord: false

    default property alias scene: sceneSlot.data

    // Sahnenin dinlediği olaylar
    signal started()
    signal tick(real dt)
    signal tapped()
    signal exitRequested()

    anchors.fill: parent

    function loadBest() {
        switch (gameId) {
        case "flappy": return UiSettings.gameFlappyBest
        case "runner": return UiSettings.gameRunnerBest
        case "reflex": return UiSettings.gameReflexBest
        }
        return 0
    }

    function saveBest(value) {
        switch (gameId) {
        case "flappy": UiSettings.gameFlappyBest = value; break
        case "runner": UiSettings.gameRunnerBest = value; break
        case "reflex": UiSettings.gameReflexBest = value; break
        }
    }

    function beginCountdown() {
        shell.score = 0
        shell.newRecord = false
        shell.hintVisible = true
        shell.phase = "countdown"
        // Once false: CountdownOverlay yalnizca onRunningChanged ile kendini
        // kuruyor, zaten true iken tekrar true yazmak sayimi baslatmaz ve oyun
        // sonsuza dek geri sayimda kalirdi.
        countdown.running = false
        countdown.running = true
    }

    function gameOver() {
        if (shell.phase === "over")
            return
        shell.phase = "over"
        // 0 = hiç kayıt yok. Refleks oyununda küçük olan iyi olduğu için ilk
        // skor her zaman rekordur, yoksa 0 asla yenilmezdi.
        var previous = shell.best
        var better = higherIsBetter ? (shell.score > previous)
                                    : (previous <= 0 || shell.score < previous)
        if (better && shell.score > 0) {
            shell.newRecord = true
            shell.best = shell.score
            shell.saveBest(shell.score)
        }
        overAnim.restart()
    }

    Component.onCompleted: {
        shell.best = shell.loadBest()
        shell.beginCountdown()
    }

    // Kare döngüsü. dt tavanlanıyor: pencere donarsa oyuncu engelin içinden geçmesin.
    FrameAnimation {
        running: shell.active && shell.usesTicker && shell.phase === "playing"
        onTriggered: shell.tick(Math.min(frameTime, 0.05))
    }

    // --- sahne yuvası ---
    Item {
        id: sceneSlot
        anchors.fill: parent
        // Geri sayım sırasında sahne görünür ama soluk: oyuncu ne geleceğini görür
        opacity: shell.phase === "countdown" ? 0.45 : 1.0

        Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
    }

    // --- girdi: tek dokunuş, yalnız oynarken ---
    MouseArea {
        anchors.fill: parent
        enabled: shell.playing
        onPressed: {
            shell.hintVisible = false
            shell.tapped()
        }
    }

    // --- HUD ---
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 22
        text: shell.score
        font.pixelSize: 54
        font.bold: true
        color: UiStyle.textColor
        opacity: shell.playing && shell.gameId !== "reflex" ? 0.9 : 0
        visible: opacity > 0.01

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26
        text: GameStrings.hint(shell.gameId)
        font.pixelSize: 18
        color: UiStyle.subtextColor
        opacity: shell.playing && shell.hintVisible ? 0.85 : 0

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // --- kapatma butonu (nefes overlay kalıbı) ---
    Rectangle {
        width: 48
        height: 48
        radius: 24
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.rightMargin: 20
        color: UiStyle.roundButtonColor
        opacity: closeArea.pressed ? 0.7 : 1.0
        z: 5

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.pixelSize: 22
            font.bold: true
            color: UiStyle.textColor
        }

        MouseArea {
            id: closeArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: shell.exitRequested()
        }
    }

    // --- 3-2-1 ---
    CountdownOverlay {
        id: countdown
        onFinished: {
            shell.phase = "playing"
            shell.started()
        }
    }

    // --- oyun sonu kartı ---
    Rectangle {
        id: overCard

        anchors.centerIn: parent
        width: Math.min(420, parent.width - 80)
        height: 292
        radius: 20
        color: UiStyle.cardPanelColor
        border.width: 1
        border.color: UiStyle.roundButtonColor
        visible: opacity > 0.01
        opacity: shell.phase === "over" ? 1 : 0
        enabled: shell.phase === "over"
        z: 4

        Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

        SequentialAnimation {
            id: overAnim
            NumberAnimation { target: overCard; property: "scale"; from: 0.9; to: 1.04; duration: 180; easing.type: Easing.OutQuad }
            NumberAnimation { target: overCard; property: "scale"; to: 1.0; duration: 220; easing.type: Easing.OutBack }
        }

        Column {
            anchors.centerIn: parent
            spacing: 10
            width: parent.width - 48

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                //: Yeni rekor!
                text: shell.newRecord ? qsTr("New record!") : qsTr("Game over")
                font.pixelSize: 22
                font.bold: true
                color: shell.newRecord ? UiStyle.buttonProgress : UiStyle.textColor
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: GameStrings.scoreLabel(shell.gameId)
                font.pixelSize: 13
                color: UiStyle.subtextColor
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: shell.higherIsBetter ? shell.score : shell.score + " ms"
                font.pixelSize: 46
                font.bold: true
                color: UiStyle.headerColor
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                //: Rekor
                text: shell.best > 0
                      ? qsTr("Best") + ": " + (shell.higherIsBetter ? shell.best : shell.best + " ms")
                      : ""
                font.pixelSize: 14
                color: UiStyle.subtextColor
            }

            Item { width: 1; height: 6 }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Rectangle {
                    objectName: "playAgainButton"
                    width: 150
                    height: 52
                    radius: 14
                    color: UiStyle.headerColor
                    scale: againArea.pressed ? 0.96 : 1.0

                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.centerIn: parent
                        //: Tekrar Oyna
                        text: qsTr("Play Again")
                        font.pixelSize: 16
                        font.bold: true
                        // UiStyle.onHeaderColor kullanilmiyor: "on"+buyuk harfle baslayan
                        // property adini QML sinyal isleyicisi saniyor, binding hic
                        // degerlendirilmiyor ve deger her temada siyah kaliyor.
                        // Ayni hesabi yapan fonksiyon dogrudan cagriliyor.
                        color: UiStyle.contrastOn(UiStyle.headerColor)
                    }

                    MouseArea {
                        id: againArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.beginCountdown()
                    }
                }

                Rectangle {
                    objectName: "exitButton"
                    width: 120
                    height: 52
                    radius: 14
                    color: UiStyle.roundButtonColor
                    scale: exitArea.pressed ? 0.96 : 1.0

                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.centerIn: parent
                        //: Çıkış
                        text: qsTr("Exit")
                        font.pixelSize: 16
                        font.bold: true
                        color: UiStyle.textColor
                    }

                    MouseArea {
                        id: exitArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.exitRequested()
                    }
                }
            }
        }
    }
}
