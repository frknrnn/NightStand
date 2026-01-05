pragma Singleton
import Qt.labs.settings
import QtCore

Settings {
    property bool wireless
    property bool bluetooth
    property int brightness
    property string themeName: "dark"
    property bool demoMode
}
