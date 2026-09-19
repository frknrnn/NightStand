pragma Singleton
import Qt.labs.settings
import QtCore

Settings {
    property bool wireless
    property bool bluetooth
    property int brightness
    property string themeName: "dark"
    property bool demoMode

    // Clock page appearance
    property string clockMode: "analog"   // "analog" | "digital"
    property int analogClockStyle: 0      // 0..4
    property int digitalClockStyle: 0     // 0..4
}
