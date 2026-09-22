import QtQuick
import QtQuick.Layouts
import "../../Style"
import "../Common"
import "BreathingPatterns.js" as BreathingPatterns
import "../../Strings"

// Tam ekran nefes egzersizi.
//
// Yerleşim bilerek layout'suz: animasyon EKRANIN TAM ORTASINDA ve alabildiğine
// büyük duruyor, mod butonları da en solda dikeyde ortalanmış dar bir sütun olarak
// onun üzerinde yüzüyor. Ekranı bir RowLayout ile bölmek animasyonu sağ yarının
// ortasına, yani merkezden kaçık ve küçük bırakıyordu.
//
// Zemin OPAK (UiStyle.baseColor): ReadingOverlay'deki "parlaklığı kök opacity'ye
// uygula" hatası burada tekrarlanmıyor, altındaki Dashboard hiç sızmıyor.
//
// Tüm animasyonları tek bir sürücü besliyor: `phaseProgress` her fazın süresi
// boyunca 0 -> 1 akıyor, `breathLevel` de ondan türetiliyor. Üç görsel de yalnızca
// bu iki değeri okuduğu için durum makinesiyle kendiliğinden senkron kalıyorlar.
//
// Ekranda hiçbir yerde saniye yok; tek rakam seans başındaki 3-2-1.
Rectangle {
    id: root

    readonly property bool active: appController.breathingMode

    // "idle" -> "counting" -> "running" -> "done" -> kapanış
    property string sessionState: "idle"

    // Seans başlayınca sol sütun kayboluyor, ekrana dokununca geri geliyor.
    property bool controlsVisible: true

    property int patternIndex: -1
    property int cycleIndex: 0
    property int phaseIndex: 0
    property real phaseProgress: 0
    property int countValue: 3

    readonly property int columnWidth: 180
    readonly property int columnMargin: 24
    readonly property int columnGap: 20

    // Animasyon ekranın ortasına göre simetrik durduğu için sol sütunun genişliği
    // iki kere düşülüyor: hem merkezde kalıyor hem de sütuna hiç çarpmıyor.
    readonly property real visualSize: Math.max(220,
            Math.min(root.height - 48,
                     root.width - 2 * (columnMargin + columnWidth + columnGap)))

    readonly property var pattern: patternIndex >= 0 ? BreathingPatterns.list[patternIndex] : null
    readonly property string visualName: pattern ? pattern.visual : ""

    // Sınır kontrolü şart: mod değişiminde patternIndex ile phaseIndex ayrı ayrı
    // yazılıyor, arada 4 fazlı bir seansın phaseIndex'i 2 fazlı bir desene düşebilir.
    readonly property string phaseKind: {
        if (!root.pattern)
            return ""
        var phase = root.pattern.phases[root.phaseIndex]
        return phase ? phase.kind : ""
    }

    // Nefesin doluluğu. Görsellerin tamamı bunu okuyor.
    readonly property real breathLevel: {
        switch (root.phaseKind) {
        case "in":     return root.phaseProgress
        case "holdIn": return 1
        case "out":    return 1 - root.phaseProgress
        default:       return 0
        }
    }

    anchors.fill: parent
    color: UiStyle.baseColor
    visible: opacity > 0 || root.active
    opacity: root.active ? 1.0 : 0.0
    z: 1100

    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    // Açılışta da kapanışta da aynı temizlik: ikinci açılışta yarım seans kalmasın.
    onActiveChanged: {
        stopAll()
        root.patternIndex = -1
        root.cycleIndex = 0
        root.phaseIndex = 0
        root.phaseProgress = 0
        root.sessionState = "idle"
        root.controlsVisible = true
    }

    function stopAll() {
        countTimer.stop()
        countAnimation.stop()
        phaseAnimation.stop()
        doneTimer.stop()
        revealGuard.stop()
    }

    // Mod seçimi. Seans ortasında başka moda basmak da buraya düşer: her şey
    // sıfırlanıp yeni bir 3-2-1 ile baştan başlar.
    function start(index) {
        stopAll()
        root.patternIndex = index
        root.cycleIndex = 0
        root.phaseIndex = 0
        root.phaseProgress = 0
        root.countValue = 3
        root.sessionState = "counting"
        // Sütun kapanıyor; aynı dokunuşun onu geri AÇMAMASI için kısa bekçi.
        revealGuard.restart()
        root.controlsVisible = false
        countAnimation.restart()
        countTimer.restart()
    }

    function beginSession() {
        root.sessionState = "running"
        startPhase()
    }

    function startPhase() {
        if (!root.pattern)
            return
        // Faz bilgisi binding üzerinden değil doğrudan okunuyor: phaseIndex az önce
        // yazıldı, aradaki binding'in tazelenmesini beklemeye gerek yok.
        var phase = root.pattern.phases[root.phaseIndex]
        phaseAnimation.stop()
        root.phaseProgress = 0
        phaseAnimation.duration = phase.ms
        // Al/ver doğal bir nefes eğrisiyle; tut fazları sabit hızla, ki kutu
        // nefesindeki işaretçi kenar boyunca eşit hızda yürüsün.
        phaseAnimation.easing.type = (phase.kind === "in" || phase.kind === "out")
                                     ? Easing.InOutSine : Easing.Linear
        phaseAnimation.start()
    }

    function advance() {
        if (!root.pattern)
            return
        var next = root.phaseIndex + 1
        if (next >= root.pattern.phases.length) {
            next = 0
            root.cycleIndex = root.cycleIndex + 1
            if (root.cycleIndex >= root.pattern.cycles) {
                finish()
                return
            }
        }
        root.phaseIndex = next
        startPhase()
    }

    function finish() {
        phaseAnimation.stop()
        root.sessionState = "done"
        doneTimer.restart()
    }

    // Faz sürücüsü. Süresi ve easing'i her fazın başında startPhase() yazıyor.
    NumberAnimation {
        id: phaseAnimation

        target: root
        property: "phaseProgress"
        from: 0
        to: 1
        onFinished: root.advance()
    }

    // 3-2-1. `running` bilerek binding almıyor (kendini durduran timer'larda
    // binding bayatlıyor); restart() ile sürülüyor.
    Timer {
        id: countTimer

        interval: 1000
        repeat: true
        onTriggered: {
            root.countValue = root.countValue - 1
            if (root.countValue <= 0) {
                countTimer.stop()
                root.beginSession()
            } else {
                countAnimation.restart()
            }
        }
    }

    Timer {
        id: doneTimer

        interval: 2000
        onTriggered: appController.breathingMode = false
    }

    // Seçim dokunuşunun "hayaleti" için kısa bekçi. onTriggered yok; yalnızca
    // `running` bir bayrak olarak okunuyor (AmbianceOverlay'deki desenin aynısı).
    Timer {
        id: revealGuard

        interval: 350
    }

    // Alttaki sayfaya dokunuş sızmasın; aynı zamanda gizlenen sütunu geri getirir.
    // Sütundan ÖNCE bildiriliyor: butonlar görünürken dokunuşu onlar alıyor.
    MouseArea {
        anchors.fill: parent
        enabled: root.active
        onClicked: {
            if (revealGuard.running)
                return
            root.controlsVisible = true
        }
    }

    // ---------------- Merkez: animasyon ve durum içerikleri ----------------

    Item {
        id: visualArea

        anchors.centerIn: parent
        width: root.visualSize
        height: root.visualSize

        Loader {
            anchors.fill: parent
            active: root.sessionState === "running"
            sourceComponent: root.visualName === "dots" ? dotsComponent
                           : root.visualName === "box"  ? boxComponent
                                                        : petalsComponent
        }

        // Faz metni tek yerde, görselin üstünde. Görseller yalnızca çevredeki
        // hareketi üretiyor.
        Text {
            anchors.centerIn: parent
            text: BreathingStrings.phaseLabel(root.phaseKind)
            font.pixelSize: 44
            font.bold: true
            color: UiStyle.textColor
            visible: root.sessionState === "running"
        }
    }

    // --- idle ---
    Text {
        anchors.centerIn: parent
        text: qsTr("Choose a mode")
        font.pixelSize: 26
        color: UiStyle.subtextColor
        visible: root.sessionState === "idle"
    }

    // --- 3-2-1 ---
    Text {
        id: countText

        anchors.centerIn: parent
        text: root.countValue > 0 ? root.countValue : ""
        font.pixelSize: 180
        font.bold: true
        color: UiStyle.textColor
        opacity: 0
        visible: root.sessionState === "counting"
    }

    SequentialAnimation {
        id: countAnimation

        ParallelAnimation {
            NumberAnimation { target: countText; property: "opacity"; from: 0; to: 1.0; duration: 200; easing.type: Easing.OutQuad }
            NumberAnimation { target: countText; property: "scale"; from: 1.4; to: 1.0; duration: 250; easing.type: Easing.OutQuad }
        }
        PauseAnimation { duration: 350 }
        ParallelAnimation {
            NumberAnimation { target: countText; property: "opacity"; from: 1.0; to: 0; duration: 200; easing.type: Easing.InQuad }
            NumberAnimation { target: countText; property: "scale"; from: 1.0; to: 0.8; duration: 250; easing.type: Easing.InQuad }
        }
    }

    // --- bitiş ---
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        visible: root.sessionState === "done"
        opacity: root.sessionState === "done" ? 1.0 : 0.0
        scale: root.sessionState === "done" ? 1.0 : 0.85

        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }

        ThemedIcon {
            Layout.alignment: Qt.AlignHCenter
            source: UiStyle.monoIconPath("check-circle")
            size: 72
            color: UiStyle.buttonProgress
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Done")
            font.pixelSize: 34
            font.bold: true
            color: UiStyle.textColor
        }
    }

    // --- rakamsız tekrar göstergesi ---
    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        spacing: 8
        visible: root.sessionState === "running"

        Repeater {
            model: root.pattern ? root.pattern.cycles : 0

            delegate: Rectangle {
                required property int index

                width: 7
                height: 7
                radius: 3.5
                antialiasing: true
                color: index < root.cycleIndex ? UiStyle.headerColor
                                               : UiStyle.roundButtonColor

                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }
    }

    // ---------------- Sol sütun: mod seçimi ----------------

    ColumnLayout {
        id: modeColumn

        anchors.left: parent.left
        anchors.leftMargin: root.columnMargin
        anchors.verticalCenter: parent.verticalCenter
        width: root.columnWidth
        spacing: 12

        opacity: root.controlsVisible ? 1.0 : 0.0
        // opacity 0 olan öğe hâlâ dokunuş yakalıyor; bu guard olmadan gizli
        // butonlar tıklanabilir kalırdı.
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

        Repeater {
            model: BreathingPatterns.list

            delegate: BreathModeButton {
                required property int index
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 62
                label: BreathingStrings.patternLabel(modelData.id)
                selected: root.patternIndex === index
                onClicked: root.start(index)
            }
        }
    }

    // ---------------- Kapat ----------------

    Rectangle {
        id: closeButton

        width: 48
        height: 48
        radius: 24
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.rightMargin: 20
        color: UiStyle.roundButtonColor
        opacity: closeArea.pressed ? 0.7 : 1.0

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        Text {
            anchors.centerIn: parent
            text: "✕"
            font.pixelSize: 22
            font.bold: true
            color: UiStyle.textColor
        }

        MouseArea {
            id: closeArea

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: appController.breathingMode = false
        }
    }

    Component {
        id: dotsComponent

        BreathDotsVisual {
            breathLevel: root.breathLevel
            phaseKind: root.phaseKind
            phaseProgress: root.phaseProgress
        }
    }

    Component {
        id: boxComponent

        BreathBoxVisual {
            breathLevel: root.breathLevel
            phaseKind: root.phaseKind
            phaseProgress: root.phaseProgress
            phaseIndex: root.phaseIndex
        }
    }

    Component {
        id: petalsComponent

        BreathPetalsVisual {
            breathLevel: root.breathLevel
            phaseKind: root.phaseKind
            phaseProgress: root.phaseProgress
        }
    }
}
