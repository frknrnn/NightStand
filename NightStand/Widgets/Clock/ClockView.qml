import QtQuick
import QtQuick.Layouts
import "../../AppSettings"
import "../../Widgets/Clock"

Item {
    id: clockView

    // Sayfadaki tüm saatler için tek zaman kaynağı
    property date now: new Date()

    readonly property int analogStyle: UiSettings.analogClockStyle
    readonly property int digitalStyle: UiSettings.digitalClockStyle
    readonly property bool analogActive: UiSettings.clockMode !== "digital"

    // Aynı anda yalnızca bir stil seçici açık olabilir
    property string openPicker: "none"   // "none" | "analog" | "digital"

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: clockView.now = new Date()
    }

    // Dışarı dokununca açık expander kapanır. RowLayout'tan ÖNCE tanımlı, yani
    // arkada: seçicilerin kendi MouseArea'ları olayı önce alır, merkezdeki saat
    // alanında hiç MouseArea olmadığı için dokunuş buraya düşer.
    MouseArea {
        anchors.fill: parent
        enabled: clockView.openPicker !== "none"
        onClicked: clockView.openPicker = "none"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Sol: analog kadran stilleri
        ClockStylePicker {
            Layout.preferredWidth: 96
            Layout.fillHeight: true

            mode: "analog"
            selectedIndex: clockView.analogStyle
            isActiveMode: clockView.analogActive
            expanded: clockView.openPicker === "analog"

            onToggleRequested: clockView.openPicker =
                (clockView.openPicker === "analog" ? "none" : "analog")

            onStyleSelected: function(index) {
                UiSettings.analogClockStyle = index
                UiSettings.clockMode = "analog"
                clockView.openPicker = "none"
            }
        }

        // Merkez: analog kadran veya tam ekran dijital saat
        Item {
            id: stage

            Layout.fillWidth: true
            Layout.fillHeight: true

            AnalogClock {
                anchors.centerIn: parent

                diameter: Math.min(stage.width, stage.height) - 16
                styleIndex: clockView.analogStyle
                digitalStyleIndex: clockView.digitalStyle
                now: clockView.now

                opacity: clockView.analogActive ? 1.0 : 0.0
                visible: opacity > 0
                scale: 0.96 + opacity * 0.04

                Behavior on opacity {
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 28

                opacity: clockView.analogActive ? 0.0 : 1.0
                visible: opacity > 0
                scale: 0.96 + opacity * 0.04

                Behavior on opacity {
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                }

                DigitalClock {
                    anchors.horizontalCenter: parent.horizontalCenter
                    styleIndex: clockView.digitalStyle
                    now: clockView.now
                    baseFontSize: Math.min(150, stage.width * 0.17, stage.height * 0.42)
                }

                DateDisplay {
                    anchors.horizontalCenter: parent.horizontalCenter
                    styleIndex: clockView.digitalStyle
                    now: clockView.now
                    baseFontSize: 28
                }
            }
        }

        // Sağ: dijital saat stilleri
        ClockStylePicker {
            Layout.preferredWidth: 96
            Layout.fillHeight: true

            mode: "digital"
            selectedIndex: clockView.digitalStyle
            isActiveMode: !clockView.analogActive
            expanded: clockView.openPicker === "digital"

            onToggleRequested: clockView.openPicker =
                (clockView.openPicker === "digital" ? "none" : "digital")

            onStyleSelected: function(index) {
                UiSettings.digitalClockStyle = index
                UiSettings.clockMode = "digital"
                clockView.openPicker = "none"
            }
        }
    }
}
