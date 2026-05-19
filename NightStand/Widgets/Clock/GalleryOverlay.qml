import QtQuick

Rectangle {
    id: root

    property int currentIndex: 0
    readonly property var slides: [
        { from: "#FF6B6B", to: "#4ECDC4" },
        { from: "#667EEA", to: "#764BA2" },
        { from: "#F7971E", to: "#FFD200" },
        { from: "#11998E", to: "#38EF7D" },
        { from: "#EE0979", to: "#FF6A00" },
        { from: "#2C3E50", to: "#FD746C" }
    ]

    anchors.fill: parent
    color: "#000000"
    visible: opacity > 0 || appController.galleryMode
    opacity: appController.galleryMode ? 1.0 : 0.0
    z: 1100

    Behavior on opacity {
        NumberAnimation { duration: 350; easing.type: Easing.InOutQuad }
    }

    onVisibleChanged: {
        if (visible) {
            currentIndex = 0
            advanceTimer.restart()
        } else {
            advanceTimer.stop()
        }
    }

    Timer {
        id: advanceTimer
        interval: 3500
        repeat: true
        running: appController.galleryMode
        onTriggered: root.currentIndex = (root.currentIndex + 1) % root.slides.length
    }

    // Stacked slides with crossfade
    Repeater {
        model: root.slides
        delegate: Rectangle {
            required property int index
            required property var modelData
            anchors.fill: parent
            opacity: root.currentIndex === index ? 1.0 : 0.0
            scale: root.currentIndex === index ? 1.0 : 1.05

            Behavior on opacity { NumberAnimation { duration: 900; easing.type: Easing.InOutQuad } }
            Behavior on scale { NumberAnimation { duration: 1200; easing.type: Easing.OutQuad } }

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: modelData.from }
                GradientStop { position: 1.0; color: modelData.to }
            }
        }
    }

    // Bottom progress dots
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Repeater {
            model: root.slides
            delegate: Rectangle {
                required property int index
                width: root.currentIndex === index ? 22 : 8
                height: 8
                radius: 4
                color: root.currentIndex === index ? "#FFFFFF" : "#66FFFFFF"

                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }
    }

    // Tap to exit
    MouseArea {
        anchors.fill: parent
        enabled: appController.galleryMode
        onClicked: {
            appController.galleryMode = false
        }
    }
}
