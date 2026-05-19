import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

Rectangle {
    id: root

    property real brightness: 0.8
    property color selectedColor: "#FFF8DC"
    property bool controlsVisible: true

    readonly property var colorPalette: [
        { name: "Warm White", value: "#FFF8DC" },
        { name: "Sepia",      value: "#F4E4BC" },
        { name: "Amber",      value: "#FFD27F" },
        { name: "Orange",     value: "#FFB870" },
        { name: "Soft Red",   value: "#FFB0B0" }
    ]

    anchors.fill: parent
    color: selectedColor
    visible: opacity > 0 || appController.readingMode
    opacity: appController.readingMode ? brightness : 0
    z: 1100

    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.InOutQuad } }
    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }

    onVisibleChanged: {
        if (visible) {
            controlsVisible = true
            hideTimer.restart()
        } else {
            hideTimer.stop()
        }
    }

    Timer {
        id: hideTimer
        interval: 4000
        repeat: false
        onTriggered: root.controlsVisible = false
    }

    // Tap on screen reveals controls
    MouseArea {
        id: revealArea
        anchors.fill: parent
        enabled: appController.readingMode
        onClicked: {
            root.controlsVisible = true
            hideTimer.restart()
        }
    }

    // Close button (top-right)
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
            onClicked: {
                appController.readingMode = false
            }
        }
    }

    // Bottom control bar
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

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        // Swallow taps so the reveal MouseArea doesn't fight with controls
        MouseArea {
            anchors.fill: parent
            enabled: root.controlsVisible
            onPressed: function(mouse) {
                hideTimer.restart()
                mouse.accepted = false
            }
            propagateComposedEvents: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Color palette
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 18

                Repeater {
                    model: root.colorPalette
                    delegate: Rectangle {
                        required property var modelData
                        width: 48
                        height: 48
                        radius: 24
                        color: modelData.value
                        border.color: root.selectedColor === modelData.value ? "#FFFFFF" : "#55000000"
                        border.width: root.selectedColor === modelData.value ? 3 : 1

                        scale: swatchArea.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }

                        MouseArea {
                            id: swatchArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedColor = parent.modelData.value
                                hideTimer.restart()
                            }
                        }
                    }
                }
            }

            // Brightness slider
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
