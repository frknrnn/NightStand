import QtQuick
import "../../Style"

// Hesap makinesinin tek tuşu. Görünüm tamamen `kind`'dan türer; çağıran taraf
// renk seçmez, böylece tuş takımı büyüdükçe palet tek yerde kalır.
Rectangle {
    id: key

    property string label: ""
    // "digit" | "operator" | "function" | "danger" | "accent"
    property string kind: "digit"
    property int fontSize: 26

    signal clicked()

    readonly property bool isAccent: kind === "accent"

    radius: 18

    color: isAccent ? UiStyle.headerColor
                    : kind === "digit" ? UiStyle.innerCardColor
                                       : UiStyle.roundButtonColor

    opacity: enabled ? 1.0 : 0.4
    scale: pressArea.pressed ? 0.94 : 1.0

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
    Behavior on scale {
        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
    }

    // Basılınca hafif bir parlama - dolu accent tuşta renk değişimi
    // okunurluğu bozacağı için yalnızca opaklıkla yapılıyor.
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: UiStyle.textColor
        opacity: pressArea.pressed ? 0.08 : 0.0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: key.label
        font.pixelSize: key.fontSize
        font.bold: key.kind !== "digit"

        // headerColor zemin üstündeki her şey onHeaderColor olmak zorunda:
        // black temasında headerColor beyaz, sabit beyaz etiket görünmez olur.
        color: key.isAccent ? UiStyle.onHeaderColor
             : key.kind === "operator" ? UiStyle.headerColor
             : key.kind === "danger"   ? UiStyle.red
             : key.kind === "function" ? UiStyle.subtextColor
                                       : UiStyle.textColor

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: key.clicked()
    }
}
