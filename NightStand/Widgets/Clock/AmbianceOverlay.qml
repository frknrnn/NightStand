import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "../../AppSettings"
import "AmbianceGradients.js" as AmbianceGradients

// Tam ekran ambiyans sahnesi.
//
// GalleryOverlay'den farkı: gradyan SABİT, kendiliğinden ilerlemiyor. Yalnızca
// çok yavaş bir "nefes" hareketi var (GPU transformu + parıltı katmanı).
//
// Parlaklık, ReadingOverlay'deki gibi kökün opacity'sine UYGULANMIYOR: kök her
// zaman opak siyah, parlaklık sadece `scene` katmanında. Böylece kısık
// parlaklıkta altındaki Dashboard sızmıyor ve kontroller okunur kalıyor.
Rectangle {
    id: root

    readonly property var gradients: AmbianceGradients.list
    property int gradientIndex: 0
    property real brightness: 0.85
    property bool controlsVisible: true

    readonly property bool active: appController.ambianceMode
    readonly property var currentGradient: gradients[gradientIndex]
    // `readonly` değil: Behavior bir yazma yakalayıcısı, salt-okunur property'de
    // çalışmaz. Değer yine de binding'den geliyor, dışarıdan kimse yazmıyor.
    property color glowColor: currentGradient.to

    anchors.fill: parent
    color: "#000000"
    visible: opacity > 0 || root.active
    opacity: root.active ? 1.0 : 0.0
    z: 1100

    Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
    Behavior on glowColor { ColorAnimation { duration: 700; easing.type: Easing.InOutQuad } }

    // Ayarlar tek seferde OKUNUYOR, binding kurulmuyor: slider ve swatch'lar bu
    // iki property'yi imperatif yazıyor, binding ilk yazımda zaten kopardı.
    Component.onCompleted: {
        root.brightness = UiSettings.ambianceBrightness
        root.gradientIndex = AmbianceGradients.indexOf(UiSettings.ambianceGradient)
    }

    onVisibleChanged: {
        if (visible) {
            controlsVisible = true
            hideTimer.restart()
        } else {
            hideTimer.stop()
            revealGuard.stop()
        }
    }

    function selectGradient(i) {
        root.gradientIndex = i
        UiSettings.ambianceGradient = root.gradients[i].id
        hideTimer.stop()        // panel zaten kapanıyor, timer'ın işi bitti
        revealGuard.restart()   // aynı dokunuş paneli geri AÇMASIN
        root.controlsVisible = false
    }

    // Dokunulmazsa panel kendi kapanır.
    //
    // `running` bilerek binding almıyor: repeat'siz bir Timer tetiklendiğinde
    // running'i kendisi false'a çekiyor, binding bayatlıyor. ClockStylePicker.qml
    // ve ExpressionDrawer.qml'deki disiplinin aynısı.
    Timer {
        id: hideTimer
        interval: 4000
        onTriggered: root.controlsVisible = false
    }

    // Seçim dokunuşunun "hayaleti" için kısa bekçi. onTriggered yok; yalnızca
    // `running` bir bayrak olarak okunuyor.
    Timer {
        id: revealGuard
        interval: 350
    }

    // ---- Sahne: parlaklık SADECE burada ----
    Item {
        id: scene

        anchors.fill: parent
        opacity: root.brightness

        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

        Item {
            id: breath

            anchors.fill: parent
            transformOrigin: Item.Center

            // Sonsuz döngülü animasyonda `running` bağlamak güvenli; kendi kendini
            // durduran repeat'siz Timer'lardan farklı. Ölçek 1.0'ın altına inmiyor
            // ki kenarlardan siyah görünmesin.
            SequentialAnimation on scale {
                running: root.active
                loops: Animation.Infinite
                NumberAnimation { from: 1.0;  to: 1.05; duration: 13000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.05; to: 1.0;  duration: 13000; easing.type: Easing.InOutSine }
            }

            // Üst üste yığılmış gradyanlar; seçim değişince çapraz geçiş
            Repeater {
                model: root.gradients
                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    anchors.fill: parent
                    opacity: root.gradientIndex === index ? 1.0 : 0.0
                    visible: opacity > 0

                    Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.InOutQuad } }

                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: modelData.from }
                        GradientStop { position: 1.0; color: modelData.to }
                    }
                }
            }

            // Nefesin renk tarafı: alttan yükselip sönen parıltı. Rengi seçili
            // gradyanın alt tonundan geliyor, o da Behavior ile geçiş yapıyor.
            Rectangle {
                id: glow

                anchors.fill: parent

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0;  color: "transparent" }
                    GradientStop { position: 0.55; color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.10) }
                    GradientStop { position: 1.0;  color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.38) }
                }

                // 9 s periyot, ölçek döngüsünün 13 s'iyle sadeleşmeyen bir oranda:
                // hareket belirgin şekilde tekrarlı görünmesin.
                SequentialAnimation on opacity {
                    running: root.active
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.0; to: 1.0; duration: 9000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.0; duration: 9000; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Ekrana dokunmak paneli geri getirir
    MouseArea {
        id: revealArea

        anchors.fill: parent
        enabled: root.active
        onClicked: {
            // Gradyan seçimi paneli kapatıyor; aynı dokunuş buraya düşerse panel
            // anında geri açılırdı. Yığın sırası gereği normalde düşmez (swatch
            // MouseArea üstte ve press'i kabul ediyor), bu savunma amaçlı: swatch
            // kenarından kayan dokunuş controlBar'ın propagateComposedEvents'li
            // zeminine düşüp buraya inebiliyor.
            if (revealGuard.running)
                return
            root.controlsVisible = true
            hideTimer.restart()
        }
    }

    // Çıkış (sağ üst)
    Rectangle {
        id: closeButton

        width: 48
        height: 48
        radius: 24
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.rightMargin: 20
        color: "#33000000"
        opacity: root.controlsVisible ? 0.85 : 0
        visible: opacity > 0   // gizliyken dokunmatik hedef olarak kalmasın

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.pixelSize: 22
            font.bold: true
            color: "#FFFFFF"
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.controlsVisible
            cursorShape: Qt.PointingHandCursor
            onClicked: appController.ambianceMode = false
        }
    }

    // Alt kontrol paneli
    Rectangle {
        id: controlBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        anchors.bottomMargin: 30
        height: 140
        radius: 24
        color: "#22000000"
        opacity: root.controlsVisible ? 1.0 : 0.0
        // opacity 0 olan item hâlâ dokunuş yakalıyor; bu guard olmadan gizli
        // swatch'lar tıklanabilir kalırdı.
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        // Panel zeminine dokunuş: timer'ı tazele, olayı alta geçir
        MouseArea {
            anchors.fill: parent
            enabled: root.controlsVisible
            propagateComposedEvents: true
            onPressed: function(mouse) {
                hideTimer.restart()
                mouse.accepted = false
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Gradyan seçimi
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 18

                Repeater {
                    model: root.gradients

                    delegate: Rectangle {
                        id: swatch

                        required property int index
                        required property var modelData

                        readonly property bool selected: root.gradientIndex === index

                        width: 48
                        height: 48
                        radius: 24
                        antialiasing: true
                        border.color: selected ? "#FFFFFF" : "#55000000"
                        border.width: selected ? 3 : 1

                        // Basma küçültmesi ile seçili büyütmesi çarpılarak birleşiyor
                        scale: (swatchArea.pressed ? 0.9 : 1.0) * (selected ? 1.08 : 1.0)

                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }

                        // Rectangle gradyanı radius'a uyuyor: daire içinde önizleme
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: swatch.modelData.from }
                            GradientStop { position: 1.0; color: swatch.modelData.to }
                        }

                        MouseArea {
                            id: swatchArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectGradient(swatch.index)
                        }
                    }
                }
            }

            // Parlaklık
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Text {
                    text: "☼"
                    font.pixelSize: 18
                    color: "#FFFFFF"
                    opacity: 0.7
                }

                QQC2.Slider {
                    id: brightnessSlider

                    Layout.fillWidth: true
                    from: 0.2
                    to: 1.0
                    value: root.brightness

                    onMoved: {
                        root.brightness = value
                        hideTimer.restart()
                    }

                    // QSettings'e sürükleme boyunca değil, bırakınca bir kez yazılıyor
                    onPressedChanged: {
                        if (!pressed)
                            UiSettings.ambianceBrightness = root.brightness
                    }

                    background: Rectangle {
                        x: brightnessSlider.leftPadding
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        implicitHeight: 8
                        width: brightnessSlider.availableWidth
                        height: implicitHeight
                        radius: 4
                        color: "#33FFFFFF"

                        Rectangle {
                            width: brightnessSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#FFFFFF"
                            radius: 4
                            opacity: 0.85
                        }
                    }

                    handle: Rectangle {
                        x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 11
                        color: "#FFFFFF"
                        border.color: "#33000000"
                        border.width: 1
                    }
                }

                Text {
                    text: "☀"
                    font.pixelSize: 22
                    color: "#FFFFFF"
                    opacity: 0.9
                }
            }
        }
    }
}
