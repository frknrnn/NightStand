import QtQuick
import QtQuick.Layouts
import "../../Style"


Item {
    id: digitalClock

    // 0 = Klasik, 1 = Sade, 2 = Mono, 3 = LCD, 4 = 12 Saat
    property int styleIndex: 0
    property date now: new Date()
    property real baseFontSize: 72
    // Önizlemelerde saniyeyi gizler, daha dar bir kutu verir
    property bool compact: false

    readonly property string monoFont: "Consolas, Menlo, Monaco, monospace"

    function pad(n) { return n < 10 ? "0" + n : "" + n }

    readonly property int hours24: now.getHours()
    readonly property int hours12: (hours24 % 12) === 0 ? 12 : (hours24 % 12)
    readonly property string amPm: hours24 < 12 ? "AM" : "PM"

    readonly property string hhmm: pad(hours24) + ":" + pad(now.getMinutes())
    readonly property string ss: pad(now.getSeconds())
    readonly property string fullTime: compact ? hhmm : hhmm + ":" + ss

    implicitWidth: loader.implicitWidth
    implicitHeight: loader.implicitHeight

    Loader {
        id: loader
        anchors.centerIn: parent
        sourceComponent: {
            switch (digitalClock.styleIndex) {
            case 1: return minimalStyle
            case 2: return monoStyle
            case 3: return lcdStyle
            case 4: return twelveHourStyle
            default: return classicStyle
            }
        }
    }

    // 0 - Klasik: kalın sans, tam saat
    Component {
        id: classicStyle

        Text {
            text: digitalClock.fullTime
            font.pixelSize: digitalClock.baseFontSize
            font.bold: true
            color: UiStyle.textColor
        }
    }

    // 1 - Sade: ince, sadece saat:dakika, harf aralıklı
    Component {
        id: minimalStyle

        Text {
            text: digitalClock.hhmm
            font.pixelSize: digitalClock.baseFontSize * 1.1
            font.weight: Font.Light
            font.letterSpacing: digitalClock.baseFontSize * 0.04
            color: UiStyle.textColor
        }
    }

    // 2 - Mono: monospace, saniye küçük ve tabana hizalı
    Component {
        id: monoStyle

        RowLayout {
            spacing: digitalClock.baseFontSize * 0.06

            Text {
                text: digitalClock.hhmm
                font.family: digitalClock.monoFont
                font.pixelSize: digitalClock.baseFontSize
                font.bold: true
                color: UiStyle.textColor
            }

            Text {
                visible: !digitalClock.compact
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: digitalClock.baseFontSize * 0.12
                text: ":" + digitalClock.ss
                font.family: digitalClock.monoFont
                font.pixelSize: digitalClock.baseFontSize * 0.4
                font.bold: true
                color: UiStyle.subtextColor
            }
        }
    }

    // 3 - LCD: arkada sönük "88:88" hayalet katmanı, üstte parlak rakamlar
    Component {
        id: lcdStyle

        Item {
            implicitWidth: ghost.implicitWidth
            implicitHeight: ghost.implicitHeight

            Text {
                id: ghost
                anchors.centerIn: parent
                text: digitalClock.fullTime.replace(/\d/g, "8")
                font.family: digitalClock.monoFont
                font.pixelSize: digitalClock.baseFontSize
                font.bold: true
                color: UiStyle.textColor
                opacity: 0.12
            }

            Text {
                anchors.centerIn: parent
                text: digitalClock.fullTime
                font.family: digitalClock.monoFont
                font.pixelSize: digitalClock.baseFontSize
                font.bold: true
                color: UiStyle.buttonProgress
            }
        }
    }

    // 4 - 12 Saat: 12'lik format + AM/PM rozeti
    Component {
        id: twelveHourStyle

        RowLayout {
            spacing: digitalClock.baseFontSize * 0.12

            Text {
                text: digitalClock.hours12 + ":" + digitalClock.pad(digitalClock.now.getMinutes())
                font.pixelSize: digitalClock.baseFontSize
                font.bold: true
                color: UiStyle.textColor
            }

            Rectangle {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: digitalClock.baseFontSize * 0.2
                Layout.preferredWidth: amPmText.implicitWidth + height * 0.8
                Layout.preferredHeight: Math.max(12, digitalClock.baseFontSize * 0.26)
                radius: height / 2
                color: UiStyle.headerColor

                Text {
                    id: amPmText
                    anchors.centerIn: parent
                    text: digitalClock.amPm
                    font.pixelSize: Math.max(8, digitalClock.baseFontSize * 0.15)
                    font.bold: true
                    color: UiStyle.baseColor
                }
            }
        }
    }
}
