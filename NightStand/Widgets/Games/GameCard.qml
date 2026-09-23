pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"
import "../../Strings"
import "../Robot"

// Bento menüsündeki oyun kartı. Görünüm sözleşmesi ActionCard/TodoPreviewCard
// ile aynı: radius 16, innerCardColor, hover'da headerColor kenarlık, basınca
// 0.96 ölçek. Önizleme gerçek bileşenlerden kurulu ama tamamen donuk
// (animated: false) - ClockStylePicker'daki donmuş önizleme kalıbı.
Rectangle {
    id: card

    property string gameId: ""
    property int best: 0
    property bool higherIsBetter: true
    property bool compact: false          // küçük kartlarda önizleme sadeleşir

    signal clicked()

    radius: 16
    color: UiStyle.innerCardColor
    border.width: 2
    border.color: pressArea.containsMouse ? UiStyle.headerColor : UiStyle.transparent

    scale: pressArea.pressed ? 0.96 : 1.0
    opacity: pressArea.pressed ? 0.9 : 1.0

    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // --- donmuş önizleme ---
    Item {
        id: preview

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        height: card.compact ? parent.height * 0.42 : parent.height * 0.54
        clip: true

        readonly property real robotSize: card.compact ? 44 : 62

        // Flappy: iki kapı bloğu arasından süzülen robot
        Loader {
            anchors.fill: parent
            active: card.gameId === "flappy"

            sourceComponent: Item {
                Rectangle {
                    x: parent.width * 0.58
                    width: 26
                    height: parent.height * 0.3
                    radius: 7
                    color: UiStyle.headerColor
                    opacity: 0.85
                }
                Rectangle {
                    x: parent.width * 0.58
                    y: parent.height * 0.62
                    width: 26
                    height: parent.height * 0.38
                    radius: 7
                    color: UiStyle.headerColor
                    opacity: 0.85
                }
                RobotCharacter {
                    x: parent.width * 0.16
                    anchors.verticalCenter: parent.verticalCenter
                    faceSize: preview.robotSize
                    animated: false
                    interactive: false
                    mouthSegments: 9
                    expression: "saskin"
                    rotation: -12
                }
            }
        }

        // Koşu: zemin çizgisi, engel ve havada robot
        Loader {
            anchors.fill: parent
            active: card.gameId === "runner"

            sourceComponent: Item {
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    y: parent.height * 0.82
                    height: 2
                    color: UiStyle.subtextColor
                    opacity: 0.55
                }
                Rectangle {
                    x: parent.width * 0.62
                    y: parent.height * 0.82 - height
                    width: 24
                    height: 34
                    radius: 6
                    color: UiStyle.headerColor
                    opacity: 0.88
                }
                RobotCharacter {
                    x: parent.width * 0.2
                    y: parent.height * 0.82 - height - 16
                    faceSize: preview.robotSize
                    animated: false
                    interactive: false
                    mouthSegments: 9
                    expression: "mutlu"
                }
            }
        }

        // Refleks: hedef halkaları ve bekleyen robot
        Loader {
            anchors.fill: parent
            active: card.gameId === "reflex"

            sourceComponent: Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.78
                    height: width
                    radius: width / 2
                    color: UiStyle.buttonProgress
                    opacity: 0.16
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.44
                    height: width
                    radius: width / 2
                    color: UiStyle.buttonProgress
                    opacity: 0.42
                }
                RobotCharacter {
                    anchors.centerIn: parent
                    faceSize: preview.robotSize
                    animated: false
                    interactive: false
                    mouthSegments: 9
                    expression: "uykulu"
                }
            }
        }
    }

    // --- metin bloğu ---
    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 14
        spacing: 3

        Text {
            width: parent.width
            text: GameStrings.title(card.gameId)
            font.pixelSize: card.compact ? 16 : 19
            font.bold: true
            color: UiStyle.textColor
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: GameStrings.tagline(card.gameId)
            font.pixelSize: 12
            color: UiStyle.subtextColor
            elide: Text.ElideRight
            visible: !card.compact
        }

        Text {
            width: parent.width
            //: Rekor
            text: card.best > 0
                  ? qsTr("Best") + ": " + (card.higherIsBetter ? card.best : card.best + " ms")
                  //: Henüz oynanmadı
                  : qsTr("Not played yet")
            font.pixelSize: 12
            font.bold: card.best > 0
            color: card.best > 0 ? UiStyle.headerColor : UiStyle.subtextColor
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.clicked()
    }
}
