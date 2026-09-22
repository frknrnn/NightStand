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
            title: qsTr("General Settings")

            content: ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // Theme Selection Section
                Text {
                    text: qsTr("Theme")
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
            title: qsTr("Robot Character")

            content: ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Text {
                    //: Karakter
                    text: qsTr("Character")
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

        // Column 3: Language
        SettingsColumn {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: qsTr("Language")

            content: ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Text {
                    text: qsTr("Interface language")
                    font.pixelSize: 14
                    font.bold: true
                    color: UiStyle.subtextColor
                }

                // Tek yazma: kalıcılaştırmayı LanguageManager kendi yapıyor,
                // UiStyle.setTheme()'in çift yazmasının aksine.
                LanguageSelector {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    selectedCode: languageManager.currentLanguage
                    onLanguageSelected: (code) => {
                        languageManager.currentLanguage = code
                    }
                }
            }
        }
    }
}
