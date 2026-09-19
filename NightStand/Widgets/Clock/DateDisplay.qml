import QtQuick
import "../../Style"

Item {
    id: dateDisplay

    // DigitalClock ile aynı stil indeksi: 0 Klasik, 1 Sade, 2 Mono, 3 LCD, 4 12 Saat
    property int styleIndex: 0
    property date now: new Date()
    property real baseFontSize: 18
    property bool compact: false

    readonly property var trLocale: Qt.locale("tr_TR")
    readonly property string monoFont: "Consolas, Menlo, Monaco, monospace"

    function formatted(pattern) {
        return now.toLocaleDateString(trLocale, pattern)
    }

    implicitWidth: loader.implicitWidth
    implicitHeight: loader.implicitHeight

    Loader {
        id: loader
        anchors.centerIn: parent
        sourceComponent: {
            switch (dateDisplay.styleIndex) {
            case 1: return minimalDate
            case 2: return monoDate
            case 3: return lcdDate
            case 4: return stackedDate
            default: return classicDate
            }
        }
    }

    // 0 - Klasik
    Component {
        id: classicDate

        Text {
            text: dateDisplay.formatted(dateDisplay.compact ? "d MMMM" : "dddd, d MMMM yyyy")
            font.pixelSize: dateDisplay.baseFontSize
            color: UiStyle.subtextColor
        }
    }

    // 1 - Sade
    Component {
        id: minimalDate

        Text {
            text: dateDisplay.formatted("d MMMM")
            font.pixelSize: dateDisplay.baseFontSize
            font.weight: Font.Light
            font.letterSpacing: dateDisplay.baseFontSize * 0.12
            color: UiStyle.subtextColor
        }
    }

    // 2 - Mono
    Component {
        id: monoDate

        Text {
            text: dateDisplay.formatted(dateDisplay.compact ? "d MMMM" : "dddd, d MMMM")
            font.family: dateDisplay.monoFont
            font.pixelSize: dateDisplay.baseFontSize
            font.letterSpacing: dateDisplay.baseFontSize * 0.16
            color: UiStyle.subtextColor
        }
    }

    // 3 - LCD
    Component {
        id: lcdDate

        Text {
            text: dateDisplay.formatted("dd.MM.yyyy")
            font.family: dateDisplay.monoFont
            font.pixelSize: dateDisplay.baseFontSize
            font.bold: true
            color: UiStyle.buttonProgress
            opacity: 0.8
        }
    }

    // 4 - 12 Saat: gün adı üstte, tarih altta
    Component {
        id: stackedDate

        Column {
            spacing: dateDisplay.baseFontSize * 0.2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: dateDisplay.formatted("dddd")
                font.pixelSize: dateDisplay.baseFontSize * 1.1
                font.bold: true
                color: UiStyle.textColor
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !dateDisplay.compact
                text: dateDisplay.formatted("d MMMM yyyy")
                font.pixelSize: dateDisplay.baseFontSize * 0.85
                color: UiStyle.subtextColor
            }
        }
    }
}
