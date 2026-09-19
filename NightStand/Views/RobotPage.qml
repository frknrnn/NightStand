import QtQuick
import QtQuick.Layouts
import "../Style"
import "../Widgets/Robot"
import "../Widgets/Robot/RobotExpressions.js" as RobotExpr

Rectangle {
    id: robotPage
    anchors.fill: parent
    color: UiStyle.baseColor

    property string current: "mutlu"
    property string pokeLine: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 60
        // Panel açılıp kapandıkça robot alanı yumuşakça değişir: visibleHeight
        // zaten Behavior'lı content.y'den türüyor, ayrı animasyon gerekmiyor.
        anchors.bottomMargin: drawer.visibleHeight + 8
        spacing: 10

        RobotSpeechBubble {
            Layout.alignment: Qt.AlignHCenter
            maxWidth: Math.min(560, robotPage.width - 120)
            text: robotPage.pokeLine !== ""
                  ? robotPage.pokeLine
                  : RobotExpr.lineOf(robotPage.current)
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RobotCharacter {
                id: bigFace
                anchors.centerIn: parent
                expression: robotPage.current
                interactive: true
                animated: robotPage.visible
                // Üst sınır 300: panel kapalıyken robot boşalan alanı gerçekten kullansın
                faceSize: Math.max(120, Math.min(300, Math.floor(Math.min(parent.height / 1.30,
                                                                          parent.width / 1.18))))

                onTapped: {
                    robotPage.pokeLine = RobotExpr.randomPoke()
                    pokeTimer.restart()
                }
            }
        }

    }

    // İfade butonları: normalde gizli, alttaki tutamaktan açılır
    ExpressionDrawer {
        id: drawer

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        current: robotPage.current

        onExpressionSelected: (id) => {
            robotPage.current = id
            robotPage.pokeLine = ""
            pokeTimer.stop()
        }
    }

    // Dokunma repliği bir süre sonra ifadenin kendi repliğine döner
    Timer {
        id: pokeTimer
        interval: 2600
        onTriggered: robotPage.pokeLine = ""
    }
}
