import QtQuick
import "../../Style"
import "../Common"

// Alttan açılan ifade paneli. Normalde yalnız tutamak görünür; tutamağa dokunmak
// veya yukarı sürüklemek ifade butonlarını yukarı çeker.
//
// content.y TEK doğruluk kaynağıdır ve ASLA binding almaz: yalnızca sürükleme ile
// settle() yazar (Widgets/Todo/TodoItem.qml'deki contentCard.x disiplininin aynısı).
Item {
    id: drawer

    property bool expanded: false
    property string current: "mutlu"

    signal expressionSelected(string id)

    readonly property real handleHeight: 48                       // dokunma tabanı
    readonly property real barAreaHeight: bar.implicitHeight + 12

    // Sayfanın robot alanını hesaplayabilmesi için: kapalıyken 48, açıkken ~150
    readonly property real visibleHeight: handleHeight + (barAreaHeight - content.y)
    readonly property real openFraction: barAreaHeight > 0
                                         ? Math.max(0, Math.min(1, 1 - content.y / barAreaHeight))
                                         : 0

    height: handleHeight + barAreaHeight

    function settle() {
        content.y = expanded ? 0 : barAreaHeight
    }

    onExpandedChanged: {
        settle()
        if (!expanded)
            autoCollapse.stop()
    }

    // Zamanlayıcı emisyon yolundan bağımsız olsun diye bileşenin KENDİ sinyaline bağlı
    onExpressionSelected: autoCollapse.restart()

    // Genişlik sonradan değişince buton boyutu -> bar yüksekliği büyür.
    // Kapalı panel eski konumda kalırsa yarı görünür takılır, o yüzden yeniden yaslanır.
    onBarAreaHeightChanged: {
        if (!handleArea.dragging)
            settle()
    }

    Component.onCompleted: settle()

    // İfade seçiminden sonra dokunulmazsa panel kendi kapanır
    Timer {
        id: autoCollapse
        interval: 4000
        onTriggered: drawer.expanded = false
    }

    Item {
        id: content

        width: parent.width
        height: parent.height

        // Sürükleme sırasında kapalı: parmak takibi gecikmesiz olsun
        Behavior on y {
            enabled: !handleArea.dragging
            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }

        // ---- Tutamak ----
        Item {
            id: handle

            width: parent.width
            height: drawer.handleHeight

            Rectangle {
                id: grip
                anchors.horizontalCenter: parent.horizontalCenter
                y: 11
                width: 46
                height: 5
                radius: height / 2
                color: UiStyle.subtextColor
                opacity: handleArea.pressed ? 1.0 : 0.55

                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            ThemedIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 24
                source: UiStyle.monoIconPath("chevron-right")
                size: 18
                color: UiStyle.subtextColor
                opacity: handleArea.pressed ? 1.0 : 0.75
                // chevron-right döndürülerek yukarı/aşağı oka çevrilir
                rotation: drawer.expanded ? 90 : -90

                Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            MouseArea {
                id: handleArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                drag.target: content
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: drawer.barAreaHeight

                property point pressPoint: Qt.point(0, 0)
                property bool tapCandidate: false
                property bool dragging: false

                onPressed: (mouse) => {
                    pressPoint = Qt.point(mouse.x, mouse.y)
                    tapCandidate = true
                    autoCollapse.stop()
                }

                onPositionChanged: (mouse) => {
                    if (Math.abs(mouse.y - pressPoint.y) > 6 || Math.abs(mouse.x - pressPoint.x) > 6) {
                        tapCandidate = false
                        dragging = true
                    }
                }

                onReleased: {
                    var wasDrag = handleArea.dragging
                    handleArea.dragging = false          // Behavior tekrar açılsın ki yaslama animasyonlu olsun

                    if (wasDrag) {
                        drawer.expanded = content.y < drawer.barAreaHeight * 0.5
                        drawer.settle()
                    } else if (handleArea.tapCandidate) {
                        drawer.expanded = !drawer.expanded
                    }
                }

                onCanceled: {
                    handleArea.dragging = false
                    handleArea.tapCandidate = false
                    drawer.settle()
                }
            }
        }

        // ---- İfade paneli ----
        Rectangle {
            id: panel

            y: drawer.handleHeight
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            height: drawer.barAreaHeight - 8
            radius: 20
            color: UiStyle.cardPanelColor
            // Sürüklerken içerik belirerek gelir
            opacity: 0.35 + 0.65 * drawer.openFraction
            enabled: drawer.expanded

            ExpressionBar {
                id: bar

                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                current: drawer.current

                onExpressionSelected: (id) => drawer.expressionSelected(id)
            }
        }
    }
}
