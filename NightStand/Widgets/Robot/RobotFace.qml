pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import "../../Style"
import "RobotExpressions.js" as RobotExpr

// Tamamen QML ile çizilmiş robot suratı.
// Tasarım ızgarası: 118u x 130u (u = faceSize / 100), yüz öğeleri kafa-yerel koordinatta.
// animated: false  -> hiç timer / sonsuz animasyon / layer yok (ifade butonlarındaki mini kopyalar).
Item {
    id: face

    // ---- genel API ----
    property string expression: "mutlu"
    property bool animated: true
    property bool interactive: false
    property real faceSize: 200
    property int mouthSegments: 15

    readonly property real u: faceSize / 100

    signal tapped()

    implicitWidth: u * 118
    implicitHeight: u * 130

    // ---- ifade parametreleri ----
    readonly property var p: RobotExpr.get(expression)

    property real eyeOpenL: p.eyeL
    property real eyeOpenR: p.eyeR
    property real eyeWidth: p.eyeW
    property real pupilScale: p.pupil
    property real pupilX: p.pupilX
    property real pupilY: p.pupilY
    property real browAngle: p.brow
    property real browY: p.browY
    property real mouthCurve: p.curve
    property real mouthOpen: p.open
    property real blush: p.blush
    property real angerTint: p.extra === "anger" ? 1 : 0
    property real eyeContent: p.extra === "heart" ? 0 : 1

    readonly property bool showGlasses: p.extra === "glasses"
    readonly property bool showHearts: p.extra === "heart"
    readonly property bool showSleep: p.extra === "sleep"
    readonly property bool showTear: p.extra === "tear"

    Behavior on eyeOpenL { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on eyeOpenR { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on eyeWidth { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on pupilScale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
    Behavior on pupilX { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on pupilY { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on browAngle { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
    Behavior on browY { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
    Behavior on mouthCurve { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
    Behavior on mouthOpen { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on blush { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on angerTint { NumberAnimation { duration: 280 } }
    Behavior on eyeContent { NumberAnimation { duration: 220 } }

    // ---- tema renkleri ----
    readonly property color lineColor: UiStyle.headerColor
    readonly property color eyeColor: UiStyle.headerColor
    readonly property color pupilColor: UiStyle.cardPanelColor
    readonly property color holeColor: UiStyle.baseColor
    readonly property color tongueColor: UiStyle.red

    // ---- canlılık: her property'nin TEK yazarı var ----
    property real blinkFactor: 1.0
    property real breathScale: 1.0
    property real bobY: 0
    property real antennaGlow: 0.55
    property real antennaFlash: 1.0
    property real heartPulse: 1.0
    property real reactRot: 0
    property real reactScale: 1.0
    property real popScale: 1.0
    property real microRot: 0
    property real microDir: 1
    property real lookX: 0
    property real lookY: 0
    property real pressScale: tapArea.pressed ? 0.965 : 1.0

    Behavior on pressScale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on lookX { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on lookY { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

    function react() {
        if (!animated)
            return
        reactAnim.restart()
        blinkAnim.loops = 1
        blinkAnim.restart()
    }

    function blink() {
        if (!animated)
            return
        blinkAnim.loops = 1
        blinkAnim.restart()
    }

    onExpressionChanged: {
        if (!animated)
            return
        popAnim.restart()
        blinkAnim.loops = 1
        blinkAnim.restart()
    }

    // Nefes alma
    SequentialAnimation on breathScale {
        running: face.animated
        loops: Animation.Infinite
        NumberAnimation { to: 1.022; duration: 1800; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.986; duration: 1800; easing.type: Easing.InOutSine }
    }

    // Hafif dikey salınım
    SequentialAnimation on bobY {
        running: face.animated
        loops: Animation.Infinite
        NumberAnimation { to: -face.u * 1.8; duration: 1800; easing.type: Easing.InOutSine }
        NumberAnimation { to: face.u * 1.2; duration: 1800; easing.type: Easing.InOutSine }
    }

    // Anten ışığı (AnalogClock'taki 12 işareti idiyomu)
    SequentialAnimation on antennaGlow {
        running: face.animated
        loops: Animation.Infinite
        NumberAnimation { to: 1.00; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.42; duration: 900; easing.type: Easing.InOutSine }
    }

    // Kalp gözler atışı
    SequentialAnimation on heartPulse {
        running: face.animated && face.showHearts
        loops: Animation.Infinite
        NumberAnimation { to: 1.14; duration: 420; easing.type: Easing.OutQuad }
        NumberAnimation { to: 1.00; duration: 520; easing.type: Easing.OutQuad }
    }

    SequentialAnimation {
        id: blinkAnim
        NumberAnimation { target: face; property: "blinkFactor"; to: 0.06; duration: 80; easing.type: Easing.InQuad }
        NumberAnimation { target: face; property: "blinkFactor"; to: 1.00; duration: 130; easing.type: Easing.OutQuad }
    }

    SequentialAnimation {
        id: popAnim
        NumberAnimation { target: face; property: "popScale"; to: 1.075; duration: 140; easing.type: Easing.OutQuad }
        NumberAnimation { target: face; property: "popScale"; to: 1.000; duration: 320; easing.type: Easing.OutBack }
    }

    SequentialAnimation {
        id: microAnim
        NumberAnimation { target: face; property: "microRot"; to: 2.2 * face.microDir; duration: 420; easing.type: Easing.InOutSine }
        NumberAnimation { target: face; property: "microRot"; to: -1.5 * face.microDir; duration: 620; easing.type: Easing.InOutSine }
        NumberAnimation { target: face; property: "microRot"; to: 0; duration: 520; easing.type: Easing.InOutSine }
    }

    // Dokunma tepkisi: sallanma + anten flaşı + squash. Hepsi kendi property'sinde,
    // bu yüzden çalışan boşta animasyonlarla çakışmaz.
    SequentialAnimation {
        id: reactAnim
        ParallelAnimation {
            SequentialAnimation {
                NumberAnimation { target: face; property: "reactRot"; to: 4.5; duration: 90; easing.type: Easing.OutQuad }
                NumberAnimation { target: face; property: "reactRot"; to: -3.5; duration: 140; easing.type: Easing.InOutQuad }
                NumberAnimation { target: face; property: "reactRot"; to: 0; duration: 240; easing.type: Easing.OutBack }
            }
            SequentialAnimation {
                NumberAnimation { target: face; property: "antennaFlash"; to: 2.1; duration: 110; easing.type: Easing.OutQuad }
                NumberAnimation { target: face; property: "antennaFlash"; to: 1.0; duration: 430; easing.type: Easing.OutCubic }
            }
            SequentialAnimation {
                NumberAnimation { target: face; property: "reactScale"; to: 0.93; duration: 90 }
                NumberAnimation { target: face; property: "reactScale"; to: 1.00; duration: 380; easing.type: Easing.OutBack }
            }
        }
    }

    // Rastgele aralıklı göz kırpma
    Timer {
        running: face.animated
        repeat: true
        interval: 2600
        onTriggered: {
            blinkAnim.loops = Math.random() < 0.22 ? 2 : 1
            blinkAnim.restart()
            interval = 1800 + Math.random() * 4200
        }
    }

    // Boşta bakış gezinmesi
    Timer {
        running: face.animated
        repeat: true
        interval: 2400
        onTriggered: {
            if (Math.random() < 0.45) {
                face.lookX = 0
                face.lookY = 0
            } else {
                face.lookX = (Math.random() * 2 - 1) * 2.6
                face.lookY = (Math.random() * 2 - 1) * 1.5
            }
            interval = 1800 + Math.random() * 3000
        }
    }

    // Mikro kafa eğimi
    Timer {
        running: face.animated
        repeat: true
        interval: 6000
        onTriggered: {
            face.microDir = Math.random() < 0.5 ? 1 : -1
            microAnim.restart()
            interval = 4500 + Math.random() * 6000
        }
    }

    // Kalp gözü: çevrilmiş kare + iki daire
    component HeartEye: Item {
        id: heart
        property real unit: 1
        property color tint: "#ff3b30"
        width: unit * 16
        height: unit * 16
        rotation: 45
        Rectangle {
            x: heart.unit * 3
            y: heart.unit * 3
            width: heart.unit * 10
            height: heart.unit * 10
            color: heart.tint
        }
        Rectangle {
            x: heart.unit * 3
            y: -heart.unit * 2
            width: heart.unit * 10
            height: heart.unit * 10
            radius: heart.unit * 5
            color: heart.tint
        }
        Rectangle {
            x: -heart.unit * 2
            y: heart.unit * 3
            width: heart.unit * 10
            height: heart.unit * 10
            radius: heart.unit * 5
            color: heart.tint
        }
    }

    Item {
        id: body
        anchors.centerIn: parent
        width: face.u * 118
        height: face.u * 130
        transformOrigin: Item.Bottom
        scale: face.breathScale * face.reactScale * face.popScale * face.pressScale
        rotation: face.reactRot + face.microRot
        transform: Translate { y: face.bobY }

        // Zemin gölgesi (nefesin tersine sıkışır)
        Rectangle {
            width: face.u * 74
            height: face.u * 10
            radius: height / 2
            color: UiStyle.headerColor
            opacity: 0.10
            x: face.u * 59 - width / 2
            y: face.u * 119
            scale: 2 - face.breathScale
        }

        // Kulaklar
        Repeater {
            model: 2
            delegate: Rectangle {
                required property int index
                readonly property bool isLeft: index === 0
                width: face.u * 10
                height: face.u * 26
                radius: face.u * 5
                color: UiStyle.roundButtonColor
                x: isLeft ? 0 : face.u * 108
                y: face.u * 66
            }
        }

        // Anten sapı
        Rectangle {
            width: face.u * 3
            height: face.u * 22
            radius: width / 2
            color: UiStyle.subtextColor
            x: face.u * 59 - width / 2
            y: face.u * 16
        }

        // Anten halesi
        Rectangle {
            width: face.u * 26
            height: width
            radius: width / 2
            color: UiStyle.headerColor
            opacity: 0.28 * face.antennaGlow * face.antennaFlash
            scale: face.antennaFlash
            x: face.u * 59 - width / 2
            y: face.u * 14 - height / 2
        }

        // Anten ampulü
        Rectangle {
            width: face.u * 12
            height: width
            radius: width / 2
            color: UiStyle.headerColor
            opacity: 0.7 + 0.3 * face.antennaGlow
            scale: 0.88 + 0.22 * face.antennaGlow
            x: face.u * 59 - width / 2
            y: face.u * 14 - height / 2
        }

        // Kafa kabuğu - sayfadaki TEK MultiEffect, üstelik statik alt ağaçta
        Rectangle {
            id: head
            x: face.u * 9
            y: face.u * 36
            width: face.u * 100
            height: face.u * 86
            radius: face.u * 30
            color: UiStyle.cardPanelColor
            border.width: face.u * 2
            border.color: UiStyle.headerColor

            layer.enabled: face.animated
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: UiStyle.headerColor
                shadowBlur: 0.35
                shadowOpacity: 0.35
                shadowVerticalOffset: 0
                shadowHorizontalOffset: 0
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: face.u * 7
                radius: face.u * 22
                color: UiStyle.innerCardColor
            }
        }

        // Yüz öğeleri: kafanın KARDEŞİ (çocuğu değil), yoksa her karede layer yenilenir.
        // Koordinatlar kafa-yereldir.
        Item {
            id: features
            x: head.x
            y: head.y
            width: head.width
            height: head.height

            // Öfke tinti
            Rectangle {
                anchors.fill: parent
                anchors.margins: face.u * 7
                radius: face.u * 22
                color: UiStyle.red
                opacity: 0.10 * face.angerTint
                visible: opacity > 0.005
            }

            // Kaşlar
            Repeater {
                model: 2
                delegate: Rectangle {
                    required property int index
                    readonly property bool isLeft: index === 0
                    width: face.u * 22
                    height: face.u * 4
                    radius: height / 2
                    color: face.lineColor
                    opacity: 0.95
                    x: face.u * (isLeft ? 32 : 68) - width / 2
                    y: face.u * (21 + face.browY) - height / 2
                    transformOrigin: Item.Center
                    rotation: isLeft ? face.browAngle : -face.browAngle
                }
            }

            // Gözler
            Repeater {
                model: 2
                delegate: Item {
                    id: eye
                    required property int index
                    readonly property bool isLeft: index === 0
                    // Göz kırpma ifadenin kapak değerini ÇARPAR, ezmez.
                    readonly property real openness: Math.max(0.06, (isLeft ? face.eyeOpenL : face.eyeOpenR) * face.blinkFactor)

                    width: face.u * 21 * face.eyeWidth
                    height: face.u * 21
                    x: face.u * (isLeft ? 32 : 68) - width / 2
                    y: face.u * 38 - height / 2

                    Rectangle {
                        id: ball
                        anchors.centerIn: parent
                        width: parent.width
                        height: Math.max(face.u * 2.4, parent.height * eye.openness)
                        radius: Math.min(width, height) / 2
                        color: face.eyeColor
                        opacity: face.eyeContent
                    }

                    Rectangle {
                        id: pupil
                        width: face.u * 7.5 * face.pupilScale
                        height: width
                        radius: width / 2
                        color: face.pupilColor
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: face.u * (face.pupilX + face.lookX)
                        anchors.verticalCenterOffset: face.u * (face.pupilY + face.lookY)
                        // Kırpma sırasında kendini söndürür, ek animasyon gerekmez
                        opacity: face.eyeContent * Math.max(0, Math.min(1, (eye.openness - 0.33) / 0.25))
                        visible: opacity > 0.01
                    }

                    Rectangle {
                        width: face.u * 3.2
                        height: width
                        radius: width / 2
                        color: UiStyle.white
                        opacity: 0.85 * pupil.opacity
                        visible: pupil.visible
                        x: pupil.x + pupil.width * 0.14
                        y: pupil.y + pupil.height * 0.10
                    }

                    HeartEye {
                        anchors.centerIn: parent
                        unit: face.u
                        tint: UiStyle.red
                        scale: face.heartPulse
                        opacity: face.showHearts ? 1 : 0
                        visible: opacity > 0.01
                        Behavior on opacity { NumberAnimation { duration: 220 } }
                    }
                }
            }

            // Yanaklar
            Repeater {
                model: 2
                delegate: Rectangle {
                    required property int index
                    readonly property bool isLeft: index === 0
                    width: face.u * 17
                    height: face.u * 10
                    radius: height / 2
                    color: UiStyle.red
                    opacity: face.blush
                    x: face.u * (isLeft ? 16 : 84) - width / 2
                    y: face.u * 57 - height / 2
                }
            }

            // Ağız boşluğu (dudak çizgisinin altında)
            Rectangle {
                id: mouthHole
                readonly property real o: Math.max(0, face.mouthOpen)
                width: face.u * 20 * (0.62 + 0.38 * o)
                height: face.u * 20 * o
                radius: Math.min(width, height) / 2
                color: face.holeColor
                visible: o > 0.02
                clip: true
                x: face.u * 50 - width / 2
                y: face.u * 62 - height / 2 + face.u * 3 * o

                Rectangle {
                    width: parent.width * 0.7
                    height: parent.height * 0.55
                    radius: height / 2
                    color: face.tongueColor
                    opacity: 0.85
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height * 0.52
                }
            }

            // Ağız: tek sayı (mouthCurve) tüm eğriyi morph eder
            Item {
                id: mouth
                readonly property real halfW: face.u * 17
                readonly property real amp: face.u * 9
                readonly property real th: face.u * 4.6

                width: face.u * 44
                height: face.u * 24
                x: face.u * 50 - width / 2
                y: face.u * 62 - height / 2
                transform: Translate { y: -face.u * 5 * Math.max(0, face.mouthOpen) }

                Repeater {
                    model: face.mouthSegments
                    delegate: Rectangle {
                        required property int index
                        readonly property real xn: face.mouthSegments > 1
                                                   ? (2 * index / (face.mouthSegments - 1)) - 1
                                                   : 0
                        width: mouth.th * (0.72 + 0.28 * (1 - Math.abs(xn)))
                        height: width
                        radius: width / 2
                        color: face.lineColor
                        x: mouth.width / 2 + xn * mouth.halfW - width / 2
                        // (1 - xn^2) - 2/3 yayı merkezler: gülümserken ağız aşağı kaymaz
                        y: mouth.height / 2
                           + face.mouthCurve * mouth.amp * ((1 - xn * xn) - 0.6667)
                           - height / 2
                    }
                }
            }

            // Güneş gözlüğü (havali) - yukarıdan iner
            Item {
                id: glasses
                width: face.u * 82
                height: face.u * 24
                x: face.u * 50 - width / 2
                y: face.u * 38 - height / 2 + (face.showGlasses ? 0 : -face.u * 14)
                opacity: face.showGlasses ? 1 : 0
                visible: opacity > 0.01

                Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }

                Rectangle {
                    width: face.u * 12
                    height: face.u * 4
                    radius: height / 2
                    color: UiStyle.headerColor
                    anchors.centerIn: parent
                }

                Repeater {
                    model: 2
                    delegate: Rectangle {
                        required property int index
                        readonly property bool isLeft: index === 0
                        width: face.u * 34
                        height: face.u * 22
                        radius: face.u * 8
                        color: UiStyle.baseColor
                        border.width: face.u * 2
                        border.color: UiStyle.headerColor
                        clip: true
                        x: isLeft ? 0 : glasses.width - width
                        y: glasses.height / 2 - height / 2

                        Rectangle {
                            width: face.u * 3.5
                            height: face.u * 26
                            color: UiStyle.white
                            opacity: 0.35
                            rotation: 24
                            x: parent.width * 0.62
                            y: -face.u * 2
                        }
                    }
                }
            }

            // Gözyaşı (uzgun)
            Rectangle {
                id: tear
                property real dropY: 0
                property real tearOpacity: 0

                width: face.u * 8
                height: width
                radius: width / 2
                topLeftRadius: face.u * 1
                rotation: 45
                color: UiStyle.headerColor
                visible: face.showTear
                x: face.u * 24
                y: face.u * 48 + (face.animated ? dropY : face.u * 6)
                opacity: face.animated ? tearOpacity : 0.9

                SequentialAnimation {
                    running: face.animated && face.showTear
                    loops: Animation.Infinite
                    ParallelAnimation {
                        NumberAnimation { target: tear; property: "dropY"; from: 0; to: face.u * 18; duration: 1500; easing.type: Easing.InQuad }
                        SequentialAnimation {
                            NumberAnimation { target: tear; property: "tearOpacity"; to: 0.9; duration: 300 }
                            PauseAnimation { duration: 700 }
                            NumberAnimation { target: tear; property: "tearOpacity"; to: 0; duration: 500 }
                        }
                    }
                    PauseAnimation { duration: 900 }
                }
            }
        }

        // Uyku "z"leri (uykulu) - kafanın sağ üstünde uçuşur
        Repeater {
            model: 3
            delegate: Text {
                id: sleepZ
                required property int index
                property real rise: 0
                property real zOpacity: 0

                readonly property real baseX: face.u * (96 + index * 7)
                readonly property real baseY: face.u * (44 - index * 11)

                text: "z"
                font.bold: true
                font.pixelSize: face.u * (16 - index * 3.5)
                color: UiStyle.subtextColor
                visible: face.showSleep
                x: baseX
                y: baseY + (face.animated ? rise : 0)
                opacity: face.animated ? zOpacity : 0.85

                SequentialAnimation {
                    running: face.animated && face.showSleep
                    PauseAnimation { duration: sleepZ.index * 550 }
                    SequentialAnimation {
                        loops: Animation.Infinite
                        ParallelAnimation {
                            NumberAnimation { target: sleepZ; property: "rise"; from: 0; to: -face.u * 14; duration: 1700; easing.type: Easing.OutQuad }
                            SequentialAnimation {
                                NumberAnimation { target: sleepZ; property: "zOpacity"; to: 0.9; duration: 450 }
                                NumberAnimation { target: sleepZ; property: "zOpacity"; to: 0; duration: 1250 }
                            }
                        }
                        PauseAnimation { duration: 400 }
                    }
                }
            }
        }
    }

    MouseArea {
        id: tapArea
        anchors.fill: body
        enabled: face.interactive
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            face.react()
            face.tapped()
        }
    }
}
