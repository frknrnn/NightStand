pragma Singleton
import Qt.labs.settings
import QtCore

Settings {
    property bool wireless
    property bool bluetooth
    property int brightness
    property bool darkTheme:true
    property int themeName
    property bool demoMode
}
