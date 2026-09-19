import QtQuick
import QtQuick.Layouts
import "../AppSettings"
import "../Style"
import "../Widgets/Settings"

Rectangle {
    id: settingspage
    anchors.fill: parent
    color: UiStyle.baseColor

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 60
        spacing: 15

        // Column 1: General Settings
        SettingsColumn {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "General Settings"

            content: ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // Theme Selection Section
                Text {
                    text: "Theme"
                    font.pixelSize: 14
                    font.bold: true
                    color: UiStyle.subtextColor
                }

                ThemeSelector {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onThemeSelected: (themeName) => {
                        console.log("Theme selected:", themeName)
                    }
                }
            }
        }

        // Column 2: Robot character
        SettingsColumn {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Robot Character"

            content: ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Text {
                    text: "Karakter"
                    font.pixelSize: 14
                    font.bold: true
                    color: UiStyle.subtextColor
                }

                CharacterSelector {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    selectedId: UiSettings.robotCharacter
                    onCharacterSelected: (id) => {
                        UiSettings.robotCharacter = id
                    }
                }
            }
        }

        // Column 3: Advanced Settings (Empty for now)
        SettingsColumn {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: "Advanced Settings"

            content: Item {
                anchors.fill: parent

                Text {
                    anchors.centerIn: parent
                    text: "Coming Soon..."
                    font.pixelSize: 14
                    color: UiStyle.subtextColor
                }
            }
        }
    }
}
