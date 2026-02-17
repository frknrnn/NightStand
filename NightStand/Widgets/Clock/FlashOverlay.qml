import QtQuick

Rectangle {
    id: flashOverlay
    anchors.fill: parent
    color: "#FFFFFF"
    visible: opacity > 0 || appController.flashMode
    opacity: appController.flashMode ? 1.0 : 0.0
    z: 1000

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    // Exit flash mode when tapped anywhere
    MouseArea {
        anchors.fill: parent
        enabled: appController.flashMode
        onClicked: {
            appController.toggleFlashMode()
        }
    }
}
