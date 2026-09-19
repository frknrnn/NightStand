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

    // headerColor zemin olarak kullanıldığında üstüne gelen yazı/ikon rengi.
    // black temada headerColor beyaz olduğu için sabit beyaz metin görünmez oluyordu.
    readonly property color onHeaderColor: contrastOn(headerColor)

    // Theme management
    readonly property string currentTheme: themeManager.currentTheme
    readonly property var availableThemes: themeManager.availableThemes
    readonly property bool isDarkTheme: themeManager.isDarkTheme

    function setTheme(themeName) {
        themeManager.currentTheme = themeName
        UiSettings.themeName = themeName
    }

    // Helper functions

    // Verilen zemin rengine göre okunabilir bir ön plan rengi döndürür.
    // Parlaklık eşiği, mevcut temaların accent renklerini beyaz bırakıp
    // sadece açık tonlu accent'lerde (black teması) siyaha düşecek şekilde seçildi.
    function contrastOn(backgroundColor) {
        var luminance = 0.299 * backgroundColor.r
                      + 0.587 * backgroundColor.g
                      + 0.114 * backgroundColor.b
        return luminance > 0.6 ? black : white
    }

    function imagePath(baseImagePath) {
        return `qrc:/NightStand/Assets/images/${baseImagePath}.png`
    }

    function themeImagePath(baseImagePath) {
        return `qrc:/NightStand/Assets/images/${baseImagePath}${(themeManager.isDarkTheme ? "-dark" : "-light")}.svg`
    }

    function iconPath(baseImagePath) {
        return `qrc:/NightStand/Assets/icons/${baseImagePath}${(themeManager.isDarkTheme ? "-dark" : "-light")}.svg`
    }

    // Tek renk ikon seti - ikon başına tek dosya, render anında ThemedIcon
    // tarafından boyanıyor; bu yüzden bilerek -dark/-light son eki yok.
    function monoIconPath(baseImagePath) {
        return `qrc:/NightStand/Assets/icons/mono/${baseImagePath}.svg`
    }

    function gifPath(baseImagePath) {
        return `qrc:/NightStand/Assets/gifs/${baseImagePath}${(themeManager.isDarkTheme ? "-dark" : "-light")}.gif`
    }
}
