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

    // Robot page character
    property string robotCharacter: "classic"   // "classic" | "eve"

    // Calculator page
    property bool calculatorScientific: false   // bilimsel panel açık mı
    property bool calculatorRadians: false      // false = derece, true = radyan

    // Ambiance mode
    property string ambianceGradient: "dusk"    // AmbianceGradients.js id
    property real ambianceBrightness: 0.85
}
