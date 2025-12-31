pragma Singleton

import QtQuick
import "../AppSettings"

Item {
    id: appstyle

    readonly property color baseColor: UiSettings.darkTheme ? "#000000" : "#FFFFFF"
    readonly property color menuPanelBackground: UiSettings.darkTheme ? "#1e1e1e" : "#EFE9E3"
    readonly property color menuSecondPanelBackground: UiSettings.darkTheme ? "#0f0f0f" : "#D9CFC7"
    readonly property color menuButtonBackground: UiSettings.darkTheme ? "#0f0f0f" : "#D9CFC7"
    readonly property color menuButtonBackgroundPressed: UiSettings.darkTheme ? "#E16428" : "#FFFFFF"
    readonly property color menuTextColor: UiSettings.darkTheme ? "#eb8e3d" : "#eb8e3d"
    readonly property color basicTextColor: UiSettings.darkTheme ? "#FFFFFF" : "#000000"
    readonly property color pasiveTextColor: UiSettings.darkTheme ? "#b4b4b4" : "#b4b4b4"
    readonly property color titleBackgroundColor: UiSettings.darkTheme ? "#FFFFFF" : "#000000"
    readonly property color listItemBackground: UiSettings.darkTheme ? "#0f0f0f" : "#D9CFC7"

    readonly property color buttonGray: UiSettings.darkTheme ? "#808080" : "#f3f3f4"
    readonly property color buttonGrayPressed: UiSettings.darkTheme ? "#707070" : "#cecfd5"
    readonly property color buttonGrayOutLine: UiSettings.darkTheme ? "#0D0D0D" : "#999999"

    readonly property color buttonBackground: UiSettings.darkTheme ? "#262626" : "#CCCCCC"
    readonly property color buttonProgress: UiSettings.darkTheme ? "#28C878" : "#19545C"
    readonly property color buttonBorderColor: UiSettings.darkTheme ? "#262626" : "#CAE0BC"

    readonly property color gradientOverlay1: "#00000000"
    readonly property color gradientOverlay2: "#1E000000"

    readonly property color background1: UiSettings.darkTheme ? "#00414A" : "#ABF2CE"
    readonly property color background2: UiSettings.darkTheme ? "#07243E" : "#E6E6E6"
    readonly property color background3: UiSettings.darkTheme ? "#262626" : "#E6E6E6"

    readonly property color backgroundBase: UiSettings.darkTheme ? "#262626" : "#000000"
    readonly property color backgroundPanelHeader: UiSettings.darkTheme ? "#262626" : "#053940"
    readonly property color backgroundPanel: UiSettings.darkTheme ? "#262626" : "#002125"

    readonly property color iconColor: UiSettings.darkTheme ? "#262626" : "#FFFFFF"

    readonly property color textColor: UiSettings.darkTheme ? "#E6E6E6" : "#FFFFFF"
    readonly property color titletextColor: UiSettings.darkTheme ? "#2CDE85" : "#898989"

    readonly property color highlightColor: UiSettings.darkTheme ? "#33676E" : "#28C878"

    readonly property color pageIndicatorColor: UiSettings.darkTheme ? "#00000000" : "#E6E6E6"
    readonly property color indicatorOutlineColor: UiSettings.darkTheme ? "#707070" : "#999999"

    readonly property color listHeader1: UiSettings.darkTheme ? "#9E00414A" : "#9E2CDE85"
    readonly property color listHeader2: UiSettings.darkTheme ? "#9E0C1C1F" : "#9E00414A"

    readonly property color white: "#FFFFFF"
    readonly property color black: "#000000"

    readonly property color red: UiSettings.darkTheme ? "#fc0022" : "#d10210"
    readonly property color green: UiSettings.darkTheme ? "#3ffc00" : "#02d10c"

    function imagePath(baseImagePath) {
        return `qrc:/EncoderReader/images/${baseImagePath}.png`
    }

    function themeImagePath(baseImagePath) {
        return `qrc:/EncoderReader/images/${baseImagePath}${(UiSettings.darkTheme ? "-dark" : "-light")}.svg`
    }

    function iconPath(baseImagePath) {
        return `qrc:/EncoderReader/icons/${baseImagePath}${(UiSettings.darkTheme ? "-dark" : "-light")}.svg`
    }

    function gifPath(baseImagePath) {
        return `qrc:/EncoderReader/icons/${baseImagePath}${(UiSettings.darkTheme ? "-dark" : "-light")}.gif`
    }
}
