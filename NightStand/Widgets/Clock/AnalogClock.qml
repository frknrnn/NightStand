import QtQuick
import "../../Style"


Rectangle {
    id: analogClock
    width: 200
    height: 200
    radius: 100
    color: UiStyle.cardPanelColor
    border.color: UiStyle.headerColor
    border.width: 3

    // Saat göstergeleri
    Repeater {
        model: 12
        Rectangle {
            width: index % 3 === 0 ? 4 : 2
            height: index % 3 === 0 ? 15 : 10
            color: UiStyle.subtextColor
            anchors.horizontalCenter: parent.horizontalCenter
            y: 10
            transformOrigin: Item.Bottom
            rotation: index * 30
        }
    }

    // Akrep
    Rectangle {
        id: hourHand
        width: 6
        height: 50
        radius: 3
        color: UiStyle.headerColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -3
        transformOrigin: Item.Bottom
    }

    // Yelkovan
    Rectangle {
        id: minuteHand
        width: 4
        height: 70
        radius: 2
        color: UiStyle.textColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -2
        transformOrigin: Item.Bottom
    }

    // Saniye
    Rectangle {
        id: secondHand
        width: 2
        height: 80
        radius: 1
        color: "#ff4444"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -1
        transformOrigin: Item.Bottom
    }

    // Merkez nokta
    Rectangle {
        width: 12
        height: 12
        radius: 6
        color: UiStyle.headerColor
        anchors.centerIn: parent
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var date = new Date()
            hourHand.rotation = (date.getHours() % 12) * 30 + date.getMinutes() * 0.5
            minuteHand.rotation = date.getMinutes() * 6 + date.getSeconds() * 0.1
            secondHand.rotation = date.getSeconds() * 6
        }
    }
}
