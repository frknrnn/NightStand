import QtQuick
import QtQuick.Effects
import "../../Style"
import "../../Widgets/Clock"


Item {
    id: analogClock

    property real diameter: 200
    // 0 = Klasik, 1 = Sade, 2 = Rakamlı, 3 = Neon, 4 = Noktalı
    property int styleIndex: 0
    property date now: new Date()
    // -1 ise kadranın içine saat/tarih yazılmaz (önizlemeler için)
    property int digitalStyleIndex: -1
    // Önizlemelerde ağır efektleri ve ince detayları kapatır
    property bool compact: false

    readonly property real r: diameter / 2

    width: diameter
    height: diameter

    readonly property bool isClassic: styleIndex === 0
    readonly property bool isMinimal: styleIndex === 1
    readonly property bool isNumerals: styleIndex === 2
    readonly property bool isNeon: styleIndex === 3
    readonly property bool isDots: styleIndex === 4

    // --- Stil paleti -------------------------------------------------------
    readonly property color accent: isNeon ? UiStyle.buttonProgress : UiStyle.headerColor
    readonly property color dialColor: (isMinimal || isDots) ? UiStyle.transparent
                                     : isNeon ? UiStyle.innerCardColor
                                     : UiStyle.cardPanelColor
    readonly property real ringWidth: isClassic ? Math.max(2, r * 0.015)
                                    : isNeon ? Math.max(2, r * 0.010)
                                    : isNumerals ? Math.max(1, r * 0.008)
                                    : 0
    readonly property bool hasGlow: (isClassic || isNeon) && !compact

    // Önizlemeler ~50px çapında; ince detaylar orada alt-piksele düşmesin diye
    // hem bir taban değer hem de bir büyütme katsayısı uygulanır.
    readonly property real tickScale: compact ? 2.2 : 1.0

    // --- İbre ölçüleri (hepsi yarıçapa oranlı) -----------------------------
    readonly property real hourW: Math.max(2, r * (isDots ? 0.050 : isMinimal ? 0.022 : 0.028))
    readonly property real hourH: isDots ? r * 0.44 : r * 0.50
    readonly property real minuteW: Math.max(1.5, r * (isDots ? 0.036 : isMinimal ? 0.016 : 0.020))
    readonly property real minuteH: isDots ? r * 0.64 : r * 0.72
    readonly property real secondW: Math.max(1, r * (isMinimal ? 0.008 : 0.010))
    readonly property real secondH: r * 0.82

    readonly property color hourColor: (isMinimal || isDots) ? UiStyle.textColor : accent
    readonly property color minuteColor: isNeon ? UiStyle.buttonProgress : UiStyle.textColor
    readonly property color secondColor: (isClassic || isNumerals) ? UiStyle.red
                                       : UiStyle.buttonProgress
    readonly property bool hasCounterWeight: isClassic || isNumerals

    // --- Açılar ------------------------------------------------------------
    readonly property real hourAngle: (now.getHours() % 12) * 30 + now.getMinutes() * 0.5
    readonly property real minuteAngle: now.getMinutes() * 6 + now.getSeconds() * 0.1
    readonly property real secondAngle: now.getSeconds() * 6

    // Dış parlama halkası (kadranın arkasında, ibreler efektten etkilenmesin)
    Rectangle {
        anchors.fill: parent
        radius: analogClock.r
        color: UiStyle.transparent
        border.width: Math.max(2, analogClock.r * 0.012)
        border.color: analogClock.accent
        visible: analogClock.hasGlow

        layer.enabled: visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: analogClock.accent
            shadowBlur: analogClock.isNeon ? 0.7 : 0.3
            shadowOpacity: analogClock.isNeon ? 0.55 : 0.35
            shadowVerticalOffset: 0
            shadowHorizontalOffset: 0
        }
    }

    // Kadran yüzeyi
    Rectangle {
        id: dial
        anchors.fill: parent
        radius: analogClock.r
        color: analogClock.dialColor
        border.width: analogClock.ringWidth
        border.color: analogClock.isNumerals ? UiStyle.roundButtonColor : analogClock.accent

        Behavior on color { ColorAnimation { duration: 250 } }
    }

    // Neon için iç halka
    Rectangle {
        anchors.centerIn: parent
        width: analogClock.diameter * 0.86
        height: width
        radius: width / 2
        color: UiStyle.transparent
        border.width: 1
        border.color: UiStyle.buttonProgress
        opacity: 0.35
        visible: analogClock.isNeon
    }

    // --- Kadran işaretleri -------------------------------------------------
    Loader {
        anchors.fill: parent
        sourceComponent: {
            switch (analogClock.styleIndex) {
            case 1: return cardinalMarkers
            case 2: return numeralMarkers
            case 3: return neonMarkers
            case 4: return dotMarkers
            default: return classicMarkers
            }
        }
    }

    // 0 - Klasik: 12 çizgi, her 3.'sü kalın, 12 yerinde nabız atan nokta
    Component {
        id: classicMarkers

        Item {
            anchors.fill: parent

            Repeater {
                model: 12

                Item {
                    id: classicTick
                    readonly property int tickIndex: index
                    readonly property bool major: tickIndex % 3 === 0

                    anchors.fill: parent
                    rotation: tickIndex * 30

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: classicTick.tickIndex !== 0
                        width: Math.max(1, analogClock.r * (classicTick.major ? 0.015 : 0.010)
                                           * analogClock.tickScale)
                        height: Math.max(2, analogClock.r * (classicTick.major ? 0.06 : 0.04)
                                            * (analogClock.compact ? 1.6 : 1.0))
                        radius: width / 2
                        color: classicTick.major ? UiStyle.textColor : UiStyle.subtextColor
                        opacity: classicTick.major ? 0.9 : 0.6
                        y: analogClock.r * 0.06
                    }
                }
            }

            // 12 işareti
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(2, analogClock.r * 0.04 * analogClock.tickScale)
                height: width
                radius: width / 2
                color: analogClock.accent
                y: analogClock.r * 0.075

                SequentialAnimation on opacity {
                    running: !analogClock.compact
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.5; duration: 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // 1 - Sade: sadece 4 ana yönde ince uzun çizgi
    Component {
        id: cardinalMarkers

        Item {
            anchors.fill: parent

            Repeater {
                model: 4

                Item {
                    id: cardinalTick
                    readonly property int tickIndex: index

                    anchors.fill: parent
                    rotation: tickIndex * 90

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.max(1, analogClock.r * 0.012 * analogClock.tickScale)
                        height: Math.max(3, analogClock.r * 0.11 * (analogClock.compact ? 1.5 : 1.0))
                        radius: width / 2
                        color: cardinalTick.tickIndex === 0 ? UiStyle.textColor : UiStyle.subtextColor
                        opacity: cardinalTick.tickIndex === 0 ? 0.95 : 0.55
                        y: analogClock.r * 0.05
                    }
                }
            }
        }
    }

    // 2 - Rakamlı: 1-12 rakamları + ince dakika çizgileri
    Component {
        id: numeralMarkers

        Item {
            anchors.fill: parent

            Repeater {
                model: analogClock.compact ? 0 : 60

                Item {
                    id: minuteTick
                    readonly property int tickIndex: index

                    anchors.fill: parent
                    rotation: tickIndex * 6

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: minuteTick.tickIndex % 5 !== 0
                        width: 1
                        height: analogClock.r * 0.025
                        color: UiStyle.subtextColor
                        opacity: 0.45
                        y: analogClock.r * 0.035
                    }
                }
            }

            Repeater {
                model: 12

                Text {
                    readonly property real angle: (index + 1) * 30 * Math.PI / 180

                    text: index + 1
                    font.pixelSize: analogClock.compact
                                    ? Math.max(7, analogClock.r * 0.32)
                                    : analogClock.r * 0.15
                    font.bold: true
                    color: UiStyle.headerColor
                    x: analogClock.r + Math.sin(angle) * analogClock.r * 0.78 - width / 2
                    y: analogClock.r - Math.cos(angle) * analogClock.r * 0.78 - height / 2
                    visible: !analogClock.compact || (index + 1) % 3 === 0
                }
            }
        }
    }

    // 3 - Neon: 60 noktalı iz, her 5.'si parlak
    Component {
        id: neonMarkers

        Item {
            anchors.fill: parent

            Repeater {
                model: analogClock.compact ? 12 : 60

                Item {
                    id: neonTick
                    readonly property int tickIndex: index
                    readonly property bool major: analogClock.compact || tickIndex % 5 === 0

                    anchors.fill: parent
                    rotation: tickIndex * (analogClock.compact ? 30 : 6)

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.max(neonTick.major ? 2.5 : 1,
                                        analogClock.r * (neonTick.major ? 0.035 : 0.016))
                        height: width
                        radius: width / 2
                        color: UiStyle.buttonProgress
                        opacity: neonTick.major ? 0.95 : 0.4
                        y: analogClock.r * 0.10
                    }
                }
            }
        }
    }

    // 4 - Noktalı: tüm iz noktalardan, her 5.'si büyük
    Component {
        id: dotMarkers

        Item {
            anchors.fill: parent

            Repeater {
                model: analogClock.compact ? 12 : 60

                Item {
                    id: dotTick
                    readonly property int tickIndex: index
                    readonly property bool major: analogClock.compact || tickIndex % 5 === 0

                    anchors.fill: parent
                    rotation: tickIndex * (analogClock.compact ? 30 : 6)

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.max(dotTick.major ? 3 : 1,
                                        analogClock.r * (dotTick.major ? 0.045 : 0.018))
                        height: width
                        radius: width / 2
                        color: dotTick.major ? UiStyle.headerColor : UiStyle.subtextColor
                        opacity: dotTick.major ? 0.9 : 0.5
                        y: analogClock.r * 0.05
                    }
                }
            }
        }
    }

    // --- Kadran içi dijital okuma (alt yarı) -------------------------------
    Loader {
        id: readout

        active: analogClock.digitalStyleIndex >= 0
        anchors.horizontalCenter: parent.horizontalCenter
        y: analogClock.r + analogClock.r * 0.18

        sourceComponent: Column {
            spacing: analogClock.r * 0.04

            DigitalClock {
                anchors.horizontalCenter: parent.horizontalCenter
                styleIndex: analogClock.digitalStyleIndex
                now: analogClock.now
                baseFontSize: analogClock.r * 0.19
            }

            DateDisplay {
                anchors.horizontalCenter: parent.horizontalCenter
                styleIndex: analogClock.digitalStyleIndex
                now: analogClock.now
                baseFontSize: analogClock.r * 0.072
            }
        }
    }

    // --- İbreler (yazının üstünde) -----------------------------------------
    Rectangle {
        id: hourHand
        width: analogClock.hourW
        height: analogClock.hourH
        radius: width / 2
        color: analogClock.hourColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        rotation: analogClock.hourAngle

        layer.enabled: !analogClock.compact
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: analogClock.isNeon ? UiStyle.buttonProgress : UiStyle.black
            shadowBlur: analogClock.isNeon ? 0.6 : 0.2
            shadowOpacity: analogClock.isNeon ? 0.7 : 0.3
            shadowVerticalOffset: analogClock.isNeon ? 0 : 2
            shadowHorizontalOffset: analogClock.isNeon ? 0 : 1
        }

        Behavior on rotation {
            RotationAnimation {
                duration: 300
                direction: RotationAnimation.Shortest
                easing.type: Easing.OutQuad
            }
        }
    }

    Rectangle {
        id: minuteHand
        width: analogClock.minuteW
        height: analogClock.minuteH
        radius: width / 2
        color: analogClock.minuteColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        rotation: analogClock.minuteAngle

        layer.enabled: !analogClock.compact
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: analogClock.isNeon ? UiStyle.buttonProgress : UiStyle.black
            shadowBlur: analogClock.isNeon ? 0.6 : 0.15
            shadowOpacity: analogClock.isNeon ? 0.6 : 0.25
            shadowVerticalOffset: analogClock.isNeon ? 0 : 2
            shadowHorizontalOffset: analogClock.isNeon ? 0 : 1
        }

        Behavior on rotation {
            RotationAnimation {
                duration: 200
                direction: RotationAnimation.Shortest
                easing.type: Easing.OutQuad
            }
        }
    }

    // Saniye ibresi (Noktalı stil hariç)
    Rectangle {
        id: secondHand
        visible: !analogClock.isDots
        width: analogClock.secondW
        height: analogClock.secondH
        radius: width / 2
        color: analogClock.secondColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        rotation: analogClock.secondAngle

        Rectangle {
            visible: analogClock.hasCounterWeight
            width: Math.max(1, analogClock.r * 0.02)
            height: Math.max(3, analogClock.r * 0.15)
            radius: width / 2
            color: analogClock.secondColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: analogClock.r * 0.03
        }

        Behavior on rotation {
            RotationAnimation {
                duration: 150
                direction: RotationAnimation.Clockwise
                easing.type: Easing.OutBack
            }
        }
    }

    // Noktalı stilde saniye, yörüngede dönen tek nokta
    Item {
        anchors.fill: parent
        visible: analogClock.isDots
        rotation: analogClock.secondAngle

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(3, analogClock.r * 0.07)
            height: width
            radius: width / 2
            color: UiStyle.red
            y: analogClock.r * 0.13
        }

        Behavior on rotation {
            RotationAnimation {
                duration: 150
                direction: RotationAnimation.Clockwise
                easing.type: Easing.OutBack
            }
        }
    }

    // --- Merkez göbek ------------------------------------------------------
    Rectangle {
        anchors.centerIn: parent
        visible: analogClock.isClassic || analogClock.isNumerals
        width: Math.max(5, analogClock.r * 0.08)
        height: width
        radius: width / 2
        color: UiStyle.cardPanelColor
        border.width: Math.max(1, analogClock.r * 0.01)
        border.color: analogClock.accent
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.max(2.5, analogClock.r * (analogClock.isDots ? 0.10
                                            : analogClock.isMinimal ? 0.035
                                            : 0.04))
        height: width
        radius: width / 2
        color: analogClock.isDots ? UiStyle.headerColor
             : analogClock.isMinimal ? UiStyle.textColor
             : analogClock.isNeon ? UiStyle.buttonProgress
             : UiStyle.red
    }
}
