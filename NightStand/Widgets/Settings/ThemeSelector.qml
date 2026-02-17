import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Item {
    id: themeSelector

    signal themeSelected(string themeName)

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Repeater {
            model: themeManager.availableThemes

            delegate: Rectangle {
                id: themeButton
                
                required property string modelData
                required property int index
                
                Layout.fillWidth: true
                height: 50
                radius: 8
                color: themeManager.currentTheme === modelData ? UiStyle.headerColor : UiStyle.innerCardColor
                border.color: themeManager.currentTheme === modelData ? UiStyle.headerColor : UiStyle.subtextColor
                border.width: themeManager.currentTheme === modelData ? 2 : 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    // Theme color preview
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: getThemePreviewColor(modelData)
                        border.color: UiStyle.white
                        border.width: 2
                    }

                    // Theme name
                    Text {
                        Layout.fillWidth: true
                        text: getThemeDisplayName(modelData)
                        font.pixelSize: 14
                        font.bold: themeManager.currentTheme === modelData
                        color: themeManager.currentTheme === modelData ? UiStyle.white : UiStyle.textColor
                    }

                    // Checkmark for selected theme
                    Text {
                        text: "✓"
                        font.pixelSize: 16
                        font.bold: true
                        color: UiStyle.white
                        visible: themeManager.currentTheme === modelData
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        UiStyle.setTheme(modelData)
                        themeSelector.themeSelected(modelData)
                    }
                }
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }
    }

    function getThemePreviewColor(themeName) {
        switch(themeName) {
            case "black": return "#FFD700"
            case "dark": return "#1a2942"
            case "light": return "#F5F5F5"
            case "blue": return "#132f4c"
            case "purple": return "#2d2640"
            case "forest": return "#1a3a22"
            default: return "#1a2942"
        }
    }

    function getThemeDisplayName(themeName) {
        switch(themeName) {
            case "black": return "Black & Yellow Theme"
            case "dark": return "Dark Theme"
            case "light": return "Light Theme"
            case "blue": return "Blue Theme"
            case "purple": return "Purple Theme"
            case "forest": return "Forest Theme"
            default: return themeName.charAt(0).toUpperCase() + themeName.slice(1)
        }
    }
}
