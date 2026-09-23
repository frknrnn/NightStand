import QtQuick
import QtQuick.Layouts
import "../AppSettings"
import "../Style"
import "../Widgets/Games"

// Oyun menüsü: bento düzeni. Solda tam boy Flappy kartı, sağda üst üste iki
// küçük kart. Oyunlar burada BAŞLAMAZ - appController.startGame() pencere
// seviyesindeki GameOverlay'i açar, çünkü tam ekran olmanın tek yolu o.
Rectangle {
    id: gamesPage

    anchors.fill: parent
    color: UiStyle.baseColor

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 60
        anchors.bottomMargin: 20
        spacing: 12

        Text {
            Layout.fillWidth: true
            //: Oyunlar
            text: qsTr("Games")
            font.pixelSize: 26
            font.bold: true
            color: UiStyle.textColor
        }

        Text {
            Layout.fillWidth: true
            Layout.bottomMargin: 2
            //: Tek dokunuşla oynanan kısa molalar
            text: qsTr("One-tap games for a short break")
            font.pixelSize: 13
            color: UiStyle.subtextColor
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 2
            rows: 2
            columnSpacing: 12
            rowSpacing: 12

            GameCard {
                Layout.row: 0
                Layout.column: 0
                Layout.rowSpan: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 2      // sol sütun geniş: bento oranı
                gameId: "flappy"
                best: UiSettings.gameFlappyBest
                onClicked: appController.startGame("flappy")
            }

            GameCard {
                Layout.row: 0
                Layout.column: 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                gameId: "runner"
                compact: true
                best: UiSettings.gameRunnerBest
                onClicked: appController.startGame("runner")
            }

            GameCard {
                Layout.row: 1
                Layout.column: 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                gameId: "reflex"
                compact: true
                best: UiSettings.gameReflexBest
                higherIsBetter: false
                onClicked: appController.startGame("reflex")
            }
        }
    }
}
