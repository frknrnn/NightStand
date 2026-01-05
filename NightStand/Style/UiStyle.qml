pragma Singleton

import QtQuick
import "../AppSettings"

Item {
    id: appstyle

    // Core colors - bound to ThemeManager
    readonly property color baseColor: themeManager.baseColor
    readonly property color cardPanelColor: themeManager.cardPanelColor
    readonly property color innerCardColor: themeManager.innerCardColor
    readonly property color roundButtonColor: themeManager.roundButtonColor
    readonly property color textColor: themeManager.textColor
    readonly property color subtextColor: themeManager.subtextColor
    readonly property color headerColor: themeManager.headerColor

    // Accent colors
    readonly property color buttonProgress: themeManager.buttonProgress
    readonly property color menuTextColor: themeManager.menuTextColor

    // Basic colors
    readonly property color white: themeManager.white
    readonly property color black: themeManager.black
    readonly property color transparent: themeManager.transparent
    readonly property color red: themeManager.red

    // Theme management
    readonly property string currentTheme: themeManager.currentTheme
    readonly property var availableThemes: themeManager.availableThemes
    readonly property bool isDarkTheme: themeManager.isDarkTheme

    function setTheme(themeName) {
        themeManager.currentTheme = themeName
        UiSettings.themeName = themeName
    }

    // Helper functions
    function imagePath(baseImagePath) {
        return `qrc:/NightStand/Assets/images/${baseImagePath}.png`
    }

    function themeImagePath(baseImagePath) {
        return `qrc:/NightStand/Assets/images/${baseImagePath}${(themeManager.isDarkTheme ? "-dark" : "-light")}.svg`
    }

    function iconPath(baseImagePath) {
        return `qrc:/NightStand/Assets/icons/${baseImagePath}${(themeManager.isDarkTheme ? "-dark" : "-light")}.svg`
    }

    function gifPath(baseImagePath) {
        return `qrc:/NightStand/Assets/gifs/${baseImagePath}${(themeManager.isDarkTheme ? "-dark" : "-light")}.gif`
    }
}
