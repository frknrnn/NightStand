pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "../../Style"
import "RobotExpressions.js" as RobotExpr

// EVE (WALL-E) karakteri: havada süzülen kafa + yumurta gövde + gövdeden ayrık kollar.
// RobotFace ile BİREBİR aynı genel API ve aynı 118u x 130u tasarım ızgarası (u = faceSize/100),
// böylece sayfa ve ifade butonlarındaki tüm boyut formülleri değişmeden çalışır.
// İfadeler RobotExpressions.js'deki AYNI tablodan türetilir; EVE'nin ağzı yoktur,
// duyguyu gözlerin yüksekliği, eğimi, rengi ve kıvrımı taşır.
Item {
    id: face

    // ---- genel API (RobotFace ile aynı) ----
    property string expression: "mutlu"
    property bool animated: true
    property bool interactive: false
    property real faceSize: 200
    property int mouthSegments: 15

    readonly property real u: faceSize / 100

    signal tapped()

    implicitWidth: u * 118
    implicitHeight: u * 130

    // Mutlu yay çözünürlüğü: büyük yüzde 9, mini ikonlarda 7 nokta
    readonly property int arcSegments: mouthSegments >= 15 ? 9 : 7

    // ---- ifade parametreleri (ortak tablo) ----
    readonly property var p: RobotExpr.get(expression)

    property real eyeOpenL: p.eyeL
    property real eyeOpenR: p.eyeR
    property real eyeWidth: p.eyeW
    property real eyeTilt: p.brow
    property real eyeShift: p.browY
    property real happyCurve: p.curve
    property real pupilX: p.pupilX
    property real pupilY: p.pupilY
    property real angerTint: p.extra === "anger" ? 1 : 0
    property real ledContent: p.extra === "heart" ? 0 : 1
    // Ağız yok: tablodaki ağız açıklığı kafanın havalanmasını sürer.
    // Şaşkında kafa yükselir, silüet değişir - 50px'lik mini ikonda ayırt edici olan bu.
    property real headLift: p.open
    // Uykuda LED'ler bekleme moduna geçer
    property real ledDim: p.extra === "sleep" ? 0.55 : 1.0

    readonly property bool showHearts: p.extra === "heart"
    readonly property bool showSleep: p.extra === "sleep"
    readonly property bool showTear: p.extra === "tear"
    readonly property bool showShine: p.extra === "glasses"

    Behavior on eyeOpenL { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on eyeOpenR { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on eyeWidth { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on eyeTilt { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
    Behavior on eyeShift { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
    Behavior on happyCurve { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
    Behavior on pupilX { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on pupilY { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Behavior on angerTint { NumberAnimation { duration: 280 } }
    Behavior on ledContent { NumberAnimation { duration: 220 } }
    Behavior on headLift { NumberAnimation { duration: 320; easing.type: Easing.OutBack } }
    Behavior on ledDim { NumberAnimation { duration: 280 } }

    // ---- filme sadık renkler (tema bağımsız gövde, tema duyarlı kenar) ----
    readonly property color shellTop: "#FBFDFF"
    readonly property color shellBottom: "#DCE4EC"
    // Açık temada beyaz gövde beyaz zeminde kaybolmasın diye kenarlık her temada var
    readonly property color shellEdge: UiStyle.isDarkTheme ? "#AEBAC8" : "#8D9AAA"
    // Piksel tabanı şart: 50px'lik mini ikonda u = 0.5, u*1.4 = 0.7px -> çizgi kaybolurdu
    readonly property real edgeWidth: Math.max(1.25, u * (UiStyle.isDarkTheme ? 1.3 : 1.8))
    readonly property color visorColor: "#0A0D11"
    readonly property color visorEdge: "#2B323B"
    readonly property color ledBlue: "#3FC9F5"
    readonly property color ledRed: "#FF4136"
    // Kızgınken LED'ler kırmızıya döner (filmdeki savunma modu)
    readonly property color ledColor: Qt.tint(ledBlue, Qt.rgba(ledRed.r, ledRed.g, ledRed.b, angerTint))

    // ---- canlılık: her property'nin TEK yazarı var ----
    property real hoverY: 0        // kafa + gövde süzülmesi
    property real armY: 0          // kollar: farklı periyot => organik gecikme
    property real ledGlow: 0.6
    property real ledFlash: 1.0
    property real blinkFactor: 1.0
    property real heartPulse: 1.0
    property real reactRot: 0
    property real reactScale: 1.0
    property real popScale: 1.0
    property real shineX: 0
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

    // Süzülme: gövde/kafa
    SequentialAnimation on hoverY {
        running: face.animated
        loops: Animation.Infinite
        NumberAnimation { to: -face.u * 3.4; duration: 1900; easing.type: Easing.InOutSine }
        NumberAnimation { to: face.u * 1.6; duration: 1900; easing.type: Easing.InOutSine }
    }

    // Kollar: bilerek farklı periyot -> gövdeyle faz kayması, gecikmeli takip hissi
    SequentialAnimation on armY {
        running: face.animated
        loops: Animation.Infinite
        NumberAnimation { to: -face.u * 2.6; duration: 2300; easing.type: Easing.InOutSine }
        NumberAnimation { to: face.u * 2.0; duration: 2300; easing.type: Easing.InOutSine }
    }

    // LED nefesi
    SequentialAnimation on ledGlow {
        running: face.animated
        loops: Animation.Infinite
        NumberAnimation { to: 1.00; duration: 1100; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.50; duration: 1100; easing.type: Easing.InOutSine }
    }

    SequentialAnimation on heartPulse {
        running: face.animated && face.showHearts
        loops: Animation.Infinite
        NumberAnimation { to: 1.14; duration: 420; easing.type: Easing.OutQuad }
        NumberAnimation { to: 1.00; duration: 520; easing.type: Easing.OutQuad }
    }

    // Vizör parlaması (havali): soldan sağa süpüren şerit
    SequentialAnimation on shineX {
        running: face.animated && face.showShine
        loops: Animation.Infinite
        NumberAnimation { from: -face.u * 24; to: face.u * 78; duration: 1500; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 1400 }
    }

    SequentialAnimation {
        id: blinkAnim
        NumberAnimation { target: face; property: "blinkFactor"; to: 0.05; duration: 70; easing.type: Easing.InQuad }
        NumberAnimation { target: face; property: "blinkFactor"; to: 1.00; duration: 120; easing.type: Easing.OutQuad }
    }

    SequentialAnimation {
        id: popAnim
        NumberAnimation { target: face; property: "popScale"; to: 1.07; duration: 140; easing.type: Easing.OutQuad }
        NumberAnimation { target: face; property: "popScale"; to: 1.00; duration: 320; easing.type: Easing.OutBack }
    }

    // Dokunma tepkisi: sallanma + LED flaşı + squash, her biri kendi property'sinde
    SequentialAnimation {
        id: reactAnim
        ParallelAnimation {
            SequentialAnimation {
                NumberAnimation { target: face; property: "reactRot"; to: 5.0; duration: 90; easing.type: Easing.OutQuad }
                NumberAnimation { target: face; property: "reactRot"; to: -3.8; duration: 150; easing.type: Easing.InOutQuad }
                NumberAnimation { target: face; property: "reactRot"; to: 0; duration: 260; easing.type: Easing.OutBack }
            }
            SequentialAnimation {
                NumberAnimation { target: face; property: "ledFlash"; to: 2.0; duration: 110; easing.type: Easing.OutQuad }
                NumberAnimation { target: face; property: "ledFlash"; to: 1.0; duration: 430; easing.type: Easing.OutCubic }
            }
            SequentialAnimation {
                NumberAnimation { target: face; property: "reactScale"; to: 0.94; duration: 90 }
                NumberAnimation { target: face; property: "reactScale"; to: 1.00; duration: 380; easing.type: Easing.OutBack }
            }
        }
    }

    // Rastgele aralıklı göz kırpma
    Timer {
        running: face.animated
        repeat: true
        interval: 2800
        onTriggered: {
            blinkAnim.loops = Math.random() < 0.22 ? 2 : 1
            blinkAnim.restart()
            interval = 1900 + Math.random() * 4300
        }
    }

    // LED'lerin vizör içinde gezinmesi
    Timer {
        running: face.animated
        repeat: true
        interval: 2400
        onTriggered: {
            if (Math.random() < 0.45) {
                face.lookX = 0
                face.lookY = 0
            } else {
                face.lookX = (Math.random() * 2 - 1) * 3.0
                face.lookY = (Math.random() * 2 - 1) * 1.2
            }
            interval = 1800 + Math.random() * 3000
        }
    }

    // Kalp gözü: 45° çevrilmiş kare + iki daire
    component HeartEye: Item {
        id: heart
        property real unit: 1
        property color tint: "#3FC9F5"
        width: unit * 14
        height: unit * 14
        rotation: 45
        Rectangle {
            x: heart.unit * 2.6
            y: heart.unit * 2.6
            width: heart.unit * 8.8
            height: heart.unit * 8.8
            color: heart.tint
        }
        Rectangle {
            x: heart.unit * 2.6
            y: -heart.unit * 1.8
            width: heart.unit * 8.8
            height: heart.unit * 8.8
            radius: heart.unit * 4.4
            color: heart.tint
        }
        Rectangle {
            x: -heart.unit * 1.8
            y: heart.unit * 2.6
            width: heart.unit * 8.8
            height: heart.unit * 8.8
            radius: heart.unit * 4.4
            color: heart.tint
        }
    }

    Item {
        id: body
        anchors.centerIn: parent
        width: face.u * 118
        height: face.u * 130
        transformOrigin: Item.Bottom
        scale: face.reactScale * face.popScale * face.pressScale
        rotation: face.reactRot

        // Zemin gölgesi: robot yükseldikçe küçülür ve soluklaşır
        Rectangle {
            id: groundShadow
            readonly property real lift: Math.max(0, -face.hoverY / (face.u * 3.4))
            width: face.u * 54 * (1 - 0.14 * lift)
            height: face.u * 8
            radius: height / 2
            color: UiStyle.black
            opacity: (UiStyle.isDarkTheme ? 0.34 : 0.20) * (1 - 0.25 * lift)
            x: face.u * 59 - width / 2
            y: face.u * 122
        }

        // Kollar: gövdeden ayrık, kendi ritminde süzülür
        Repeater {
            model: 2
            delegate: Rectangle {
                required property int index
                readonly property bool isLeft: index === 0

                width: face.u * 12
                height: face.u * 32
                radius: width / 2
                color: face.shellTop
                border.width: face.edgeWidth
                border.color: face.shellEdge
                x: isLeft ? face.u * 6 : face.u * 100
                y: face.u * 70
                rotation: isLeft ? -7 : 7
                transform: Translate { y: face.armY }
            }
        }

        // Yumurta gövde
        Shape {
            id: bodyShell
            x: face.u * 27
            y: face.u * 61
            width: face.u * 64
            height: face.u * 66
            preferredRendererType: Shape.CurveRenderer
            transform: Translate { y: face.hoverY * 0.55 }

            ShapePath {
                strokeColor: face.shellEdge
                strokeWidth: face.edgeWidth
                fillGradient: LinearGradient {
                    x1: 0
                    y1: 0
                    x2: 0
                    y2: bodyShell.height
                    GradientStop { position: 0.0; color: face.shellTop }
                    GradientStop { position: 1.0; color: face.shellBottom }
                }
                PathAngleArc {
                    centerX: bodyShell.width / 2
                    centerY: bodyShell.height / 2
                    radiusX: bodyShell.width / 2 - face.u * 0.7
                    radiusY: bodyShell.height / 2 - face.u * 0.7
                    startAngle: 0
                    sweepAngle: 360
                    moveToStart: true
                }
            }
        }

        // Kafa grubu: gövdeden bağımsız süzülür (aradaki boşluk nefes alır)
        Item {
            id: headGroup
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            // Süzülme + ifadeye bağlı havalanma (şaşkında kafa yükselir, boşluk açılır)
            transform: Translate { y: face.hoverY - face.u * 2.6 * face.headLift }

            // Kafa kabuğu - TEK MultiEffect, statik alt ağaçta (vizör kardeşi, çocuğu değil)
            Shape {
                id: headShell
                x: face.u * 23
                y: face.u * 5
                width: face.u * 72
                height: face.u * 50
                preferredRendererType: Shape.CurveRenderer

                layer.enabled: face.animated
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: UiStyle.black
                    shadowBlur: 0.4
                    shadowOpacity: 0.35
                    shadowVerticalOffset: face.u * 2
                    shadowHorizontalOffset: 0
                }

                ShapePath {
                    strokeColor: face.shellEdge
                    strokeWidth: face.edgeWidth
                    fillGradient: LinearGradient {
                        x1: 0
                        y1: 0
                        x2: 0
                        y2: headShell.height
                        GradientStop { position: 0.0; color: face.shellTop }
                        GradientStop { position: 1.0; color: face.shellBottom }
                    }
                    PathAngleArc {
                        centerX: headShell.width / 2
                        centerY: headShell.height / 2
                        radiusX: headShell.width / 2 - face.u * 0.7
                        radiusY: headShell.height / 2 - face.u * 0.7
                        startAngle: 0
                        sweepAngle: 360
                        moveToStart: true
                    }
                }
            }

            // Vizör: siyah cam. clip -> parlama şeridi ve damla dışarı taşmaz.
            Rectangle {
                id: visor
                x: face.u * 31
                y: face.u * 16
                width: face.u * 56
                height: face.u * 30
                radius: height / 2
                color: face.visorColor
                border.width: face.u * 1
                border.color: face.visorEdge
                clip: true

                // Kızgınlık: vizörde kırmızı is
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: face.ledRed
                    opacity: 0.16 * face.angerTint
                    visible: opacity > 0.005
                }

                // Vizör parlaması (havali). Statik kopyada ortada durur.
                Rectangle {
                    width: face.u * 9
                    height: face.u * 70
                    color: UiStyle.white
                    opacity: 0.22
                    rotation: 22
                    visible: face.showShine
                    x: face.animated ? face.shineX : face.u * 30
                    y: -face.u * 20
                }

                // İki LED göz
                Repeater {
                    model: 2
                    delegate: Item {
                        id: eye
                        required property int index
                        readonly property bool isLeft: index === 0
                        readonly property real openness: Math.max(0.05,
                            (isLeft ? face.eyeOpenL : face.eyeOpenR) * face.blinkFactor)
                        // Yay payı: eğri pozitifken LED çubuk yerini kıvrık yaya bırakır
                        readonly property real arc: Math.max(0, face.happyCurve)

                        width: face.u * 13 * face.eyeWidth
                        height: face.u * 17
                        x: visor.width / 2 + face.u * (eye.isLeft ? -12 : 12)
                           + face.u * (face.pupilX + face.lookX) - width / 2
                        y: visor.height / 2 + face.u * (face.pupilY * 0.6 + face.lookY * 0.6 + face.eyeShift * 0.35)
                           - height / 2
                        rotation: isLeft ? face.eyeTilt : -face.eyeTilt
                        transformOrigin: Item.Center

                        // Yumuşak parıltı halesi
                        Rectangle {
                            anchors.centerIn: ledBar
                            width: ledBar.width + face.u * 7
                            height: ledBar.height + face.u * 7
                            radius: height / 2
                            color: face.ledColor
                            opacity: 0.24 * face.ledGlow * face.ledFlash * face.ledContent * face.ledDim * (1 - eye.arc)
                            visible: opacity > 0.01
                        }

                        // LED çubuk (nötr/üzgün/kızgın/uykulu)
                        Rectangle {
                            id: ledBar
                            anchors.centerIn: parent
                            width: parent.width
                            height: Math.max(face.u * 2.2, parent.height * eye.openness)
                            radius: Math.min(width, height) / 2
                            color: face.ledColor
                            opacity: face.ledContent * face.ledDim * (1 - eye.arc)
                            visible: opacity > 0.01

                            // İç çekirdek: LED'e derinlik verir
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width * 0.45
                                height: Math.max(face.u * 1.2, parent.height * 0.42)
                                radius: Math.min(width, height) / 2
                                color: UiStyle.white
                                opacity: 0.55 * face.ledGlow
                            }
                        }

                        // Mutlu yay: ağızdaki nokta-parabol tekniğinin gözdeki karşılığı
                        Item {
                            id: happyArc
                            anchors.centerIn: parent
                            width: parent.width + face.u * 3
                            height: face.u * 12
                            opacity: face.ledContent * face.ledDim * eye.arc
                            visible: opacity > 0.01

                            Repeater {
                                model: face.arcSegments
                                delegate: Rectangle {
                                    required property int index
                                    readonly property real xn: face.arcSegments > 1
                                                               ? (2 * index / (face.arcSegments - 1)) - 1
                                                               : 0
                                    width: face.u * 4.4 * (0.7 + 0.3 * (1 - Math.abs(xn)))
                                    height: width
                                    radius: width / 2
                                    color: face.ledColor
                                    x: happyArc.width / 2 + xn * (happyArc.width / 2 - width / 2) - width / 2
                                    // Yukarı kıvrık yay: uçlar aşağıda, orta yukarıda
                                    y: happyArc.height / 2
                                       + eye.arc * face.u * 5 * ((1 - xn * xn) - 0.6667) * -1
                                       - height / 2
                                }
                            }
                        }

                        // Kalp gözler (asik)
                        HeartEye {
                            anchors.centerIn: parent
                            unit: face.u
                            tint: face.ledBlue
                            scale: face.heartPulse
                            opacity: face.showHearts ? 1 : 0
                            visible: opacity > 0.01
                            Behavior on opacity { NumberAnimation { duration: 220 } }
                        }
                    }
                }

                // Damla (uzgun): sol gözün altından süzülüp vizörün alt kenarında kaybolur
                Rectangle {
                    id: drop
                    property real dropY: 0
                    property real dropOpacity: 0

                    width: face.u * 6
                    height: width
                    radius: width / 2
                    topLeftRadius: face.u * 1
                    rotation: 45
                    color: face.ledBlue
                    visible: face.showTear
                    x: visor.width / 2 - face.u * 15
                    y: visor.height / 2 + face.u * 2 + (face.animated ? dropY : face.u * 4)
                    opacity: face.animated ? dropOpacity : 0.9

                    SequentialAnimation {
                        running: face.animated && face.showTear
                        loops: Animation.Infinite
                        ParallelAnimation {
                            NumberAnimation { target: drop; property: "dropY"; from: 0; to: face.u * 14; duration: 1500; easing.type: Easing.InQuad }
                            SequentialAnimation {
                                NumberAnimation { target: drop; property: "dropOpacity"; to: 0.95; duration: 300 }
                                PauseAnimation { duration: 600 }
                                NumberAnimation { target: drop; property: "dropOpacity"; to: 0; duration: 500 }
                            }
                        }
                        PauseAnimation { duration: 900 }
                    }
                }
            }
        }

        // Uyku "z"leri (uykulu): kafanın sağ üstünde uçuşur
        Repeater {
            model: 3
            delegate: Text {
                id: sleepZ
                required property int index
                property real rise: 0
                property real zOpacity: 0

                readonly property real baseX: face.u * (94 + index * 7)
                readonly property real baseY: face.u * (18 - index * 8)

                text: "z"
                font.bold: true
                font.pixelSize: face.u * (15 - index * 3.2)
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
                            NumberAnimation { target: sleepZ; property: "rise"; from: 0; to: -face.u * 13; duration: 1700; easing.type: Easing.OutQuad }
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
