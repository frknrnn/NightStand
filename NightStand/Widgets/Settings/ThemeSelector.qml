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
                        // Kenarlık, altındaki satır zeminine göre hesaplanıyor:
                        // seçiliyken headerColor, değilken innerCardColor. Sabit
                        // beyaz bırakılınca light temasında açık zemin üstünde
                        // açık önizleme noktası kayboluyordu.
                        border.color: UiStyle.contrastOn(themeButton.color)
                        border.width: 2
                    }

                    // Theme name
                    Text {
                        Layout.fillWidth: true
                        text: getThemeDisplayName(modelData)
                        font.pixelSize: 14
                        font.bold: themeManager.currentTheme === modelData
                        // Seçili satırın zemini headerColor; black temasında bu
                        // beyaz olduğu için sabit beyaz yazı görünmez oluyordu.
                        color: themeManager.currentTheme === modelData ? UiStyle.onHeaderColor
                                                                       : UiStyle.textColor
                    }

                    // Checkmark for selected theme
                    Text {
                        text: "✓"
                        font.pixelSize: 16
                        font.bold: true
                        color: UiStyle.onHeaderColor
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
            case "black": return "#0a0a0a"
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
            case "black": return qsTr("Black Theme")
            case "dark": return qsTr("Dark Theme")
            case "light": return qsTr("Light Theme")
            case "blue": return qsTr("Blue Theme")
            case "purple": return qsTr("Purple Theme")
            case "forest": return qsTr("Forest Theme")
            default: return themeName.charAt(0).toUpperCase() + themeName.slice(1)
        }
    }
}
