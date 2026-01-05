pragma Singleton

import QtQuick
import "../AppSettings"

Item {
    id: appstyle

    // Core colors
    readonly property color baseColor: UiSettings.darkTheme ? "#000000" : "#FFFFFF"
    readonly property color cardPanelColor: UiSettings.darkTheme ? "#1a2942" : "#FFFFFF"
    readonly property color innerCardColor: UiSettings.darkTheme ? "#223548" : "#FFFFFF"
    readonly property color roundButtonColor: UiSettings.darkTheme ? "#2a3f5f" : "#FFFFFF"
    readonly property color textColor: UiSettings.darkTheme ? "#FFFFFF" : "#000000"
    readonly property color subtextColor: UiSettings.darkTheme ? "#7a8fa8" : "#666666"
    readonly property color headerColor: UiSettings.darkTheme ? "#6366f1" : "#4f46e5"

    // Accent colors
    readonly property color buttonProgress: UiSettings.darkTheme ? "#28C878" : "#19545C"
    readonly property color menuTextColor: UiSettings.darkTheme ? "#eb8e3d" : "#eb8e3d"

    // Basic colors
    readonly property color white: "#FFFFFF"
    readonly property color black: "#000000"
    readonly property color transparent: "transparent"
    readonly property color red: UiSettings.darkTheme ? "#fc0022" : "#d10210"

    // Helper functions
    function imagePath(baseImagePath) {
        return `qrc:/NightStand/Assets/images/${baseImagePath}.png`
    }

    function themeImagePath(baseImagePath) {
        return `qrc:/NightStand/Assets/images/${baseImagePath}${(UiSettings.darkTheme ? "-dark" : "-light")}.svg`
    }

    function iconPath(baseImagePath) {
        return `qrc:/NightStand/Assets/icons/${baseImagePath}${(UiSettings.darkTheme ? "-dark" : "-light")}.svg`
    }

    function gifPath(baseImagePath) {
        return `qrc:/NightStand/Assets/gifs/${baseImagePath}${(UiSettings.darkTheme ? "-dark" : "-light")}.gif`
    }
}
