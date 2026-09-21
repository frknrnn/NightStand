import QtQuick
import QtQuick.Controls
import "../../Style"

// Üst bar Wi-Fi durum butonu. Gövdesi Dashboard'daki diğer RoundButton'larla
// birebir aynı; farkı sağ alttaki durum noktası ve bağlı değilken solması.
//
// Desteklenmeyen platformda (Windows, nmcli'siz Linux) buton hiç görünmez.
// Durumsuz: wifiManager'ı yalnızca okur, tıklamayı `clicked` ile dışarı verir.
RoundButton {
    id: root

    visible: wifiManager.supported

    implicitWidth: 50
    implicitHeight: 50

    icon.source: UiStyle.iconPath("wifi")
    icon.width: 28
    icon.height: 28
    icon.color: UiStyle.textColor

    opacity: wifiManager.connected ? 1.0 : 0.55

    Behavior on opacity {
        NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
    }

    background: Rectangle {
        color: UiStyle.roundButtonColor
        radius: 25
    }

    // Durum noktası. Yanıp sönme doğrudan `opacity` üzerinde DEĞİL, bağlaması
    // olmayan ayrı bir `blink` özelliği üzerinde çalışıyor: bir animasyon
    // hedeflediği özelliğin bağlamasını kalıcı olarak koparır.
    Rectangle {
        id: badge

        property real blink: 1.0

        width: 11
        height: 11
        radius: width / 2

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 7
        anchors.bottomMargin: 7

        color: wifiManager.connected ? UiStyle.buttonProgress
             : wifiManager.lastError !== "" ? UiStyle.red
             : UiStyle.subtextColor

        border.width: 2
        border.color: UiStyle.roundButtonColor
        opacity: badge.blink

        Behavior on color { ColorAnimation { duration: 250 } }

        // alwaysRunToEnd: her tur 1.0'da bittiği için durdurulduğunda nokta
        // yarı saydam takılı kalmaz.
        SequentialAnimation on blink {
            running: wifiManager.connecting
            loops: Animation.Infinite
            alwaysRunToEnd: true

            NumberAnimation { from: 1.0; to: 0.2; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 0.2; to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
        }
    }
}
