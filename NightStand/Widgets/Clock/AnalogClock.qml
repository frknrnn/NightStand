import QtQuick
import QtQuick.Effects
import "../../Style"


Rectangle {
    id: analogClock
    width: 200
    height: 200
    radius: 100
    color: UiStyle.cardPanelColor
    border.color: UiStyle.headerColor
    border.width: 3

    // Outer glow effect
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: UiStyle.headerColor
        shadowBlur: 0.3
        shadowOpacity: 0.4
        shadowVerticalOffset: 0
        shadowHorizontalOffset: 0
    }

    // Saat 12 işareti - küçük parlak nokta
    Rectangle {
        id: twelveMarker
        width: 8
        height: 8
        radius: 4
        color: UiStyle.headerColor
        anchors.horizontalCenter: parent.horizontalCenter
        y: 15

        // Glow animation for 12 marker
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.5; duration: 1500; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
        }
    }

    // Saat göstergeleri (12 hariç)
    Repeater {
        model: 12
        Rectangle {
            visible: index !== 0
            width: index % 3 === 0 ? 3 : 2
            height: index % 3 === 0 ? 12 : 8
            color: index % 3 === 0 ? UiStyle.textColor : UiStyle.subtextColor
            opacity: index % 3 === 0 ? 0.9 : 0.6
            anchors.horizontalCenter: parent.horizontalCenter
            y: 12
            transformOrigin: Item.Bottom
            transform: [
                Translate { y: 88 },
                Rotation { angle: index * 30; origin.x: width / 2; origin.y: 88 }
            ]
        }
    }

    // Akrep (Hour hand)
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

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: UiStyle.black
            shadowBlur: 0.2
            shadowOpacity: 0.3
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 1
        }

        Behavior on rotation {
            RotationAnimation {
                duration: 300
                direction: RotationAnimation.Shortest
                easing.type: Easing.OutQuad
            }
        }
    }

    // Yelkovan (Minute hand)
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

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: UiStyle.black
            shadowBlur: 0.15
            shadowOpacity: 0.25
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 1
        }

        Behavior on rotation {
            RotationAnimation {
                duration: 200
                direction: RotationAnimation.Shortest
                easing.type: Easing.OutQuad
            }
        }
    }

    // Saniye (Second hand)
    Rectangle {
        id: secondHand
        width: 2
        height: 80
        radius: 1
        color: UiStyle.red
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -1
        transformOrigin: Item.Bottom

        // Counter weight
        Rectangle {
            width: 4
            height: 15
            radius: 2
            color: UiStyle.red
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 3
        }

        Behavior on rotation {
            RotationAnimation {
                duration: 150
                direction: RotationAnimation.Clockwise
                easing.type: Easing.OutBack
            }
        }
    }

    // Merkez nokta - dış halka
    Rectangle {
        width: 16
        height: 16
        radius: 8
        color: UiStyle.cardPanelColor
        border.color: UiStyle.headerColor
        border.width: 2
        anchors.centerIn: parent
    }

    // Merkez nokta - iç
    Rectangle {
        width: 8
        height: 8
        radius: 4
        color: UiStyle.red
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
