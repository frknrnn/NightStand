cmake_minimum_required(VERSION 3.16)

project(NightStand VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Multimedia)
# Optional: no C++ code uses QuickShapes, QML imports QtQuick.Shapes at runtime.
# Older Qt only ships it as the private QuickShapesPrivate module, so a
# REQUIRED lookup fails on distro Qt (e.g. Qt 6.8 on Raspberry Pi OS).
find_package(Qt6 OPTIONAL_COMPONENTS QuickShapes)
find_package(Qt6 REQUIRED COMPONENTS VirtualKeyboard)
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

qt_standard_project_setup(
    REQUIRES 6.2
    I18N_SOURCE_LANGUAGE en
    I18N_TRANSLATED_LANGUAGES tr
)

qt_add_executable(appNightStand
    main.cpp
)

qt_add_qml_module(appNightStand
    URI NightStand
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES AppSettings/qmldir
        RESOURCES Style/qmldir
        QML_FILES AppSettings/UiSettings.qml
        QML_FILES Style/UiStyle.qml
        SOURCES Models/modelmanager.h Models/modelmanager.cpp
        SOURCES ViewModels/appviewmodel.h ViewModels/appviewmodel.cpp
        QML_FILES Widgets/SquareButton.qml
        RESOURCES Assets/icons/back-dark.svg Assets/icons/back-light.svg Assets/icons/bearleft-dark.svg Assets/icons/bearleft-light.svg Assets/icons/bearright-dark.svg Assets/icons/bearright-light.svg Assets/icons/bell-dark.svg Assets/icons/bell-light.svg Assets/icons/bluetooth-dark.svg Assets/icons/bluetooth-light.svg Assets/icons/clock-dark.svg Assets/icons/clock-light.svg Assets/icons/connecting2x-dark.gif Assets/icons/connecting2x-light.gif Assets/icons/darkmode-dark.svg Assets/icons/darkmode-light.svg Assets/icons/demomode-dark.svg Assets/icons/demomode-light.svg Assets/icons/downArrow-dark.svg Assets/icons/downArrow-light.svg Assets/icons/drop-dark.svg Assets/icons/drop-light.svg Assets/icons/error2x-dark.gif Assets/icons/error2x-light.gif Assets/icons/forward-dark.svg Assets/icons/forward-light.svg Assets/icons/generalsettings-dark.svg Assets/icons/generalsettings-light.svg Assets/icons/hearth-dark.svg Assets/icons/hearth-light.svg Assets/icons/keyboard.svg Assets/icons/leftArrow-dark.svg Assets/icons/leftArrow-light.svg Assets/icons/left-dark.svg Assets/icons/left-light.svg Assets/icons/lightleft-dark.svg Assets/icons/lightleft-light.svg Assets/icons/lightright-dark.svg Assets/icons/lightright-light.svg Assets/icons/location-dark.svg Assets/icons/location-light.svg Assets/icons/maps-dark.svg Assets/icons/maps-light.svg Assets/icons/nmi-dark.svg Assets/icons/nmi-light.svg Assets/icons/notification-dark.svg Assets/icons/notification-light.svg Assets/icons/plus-dark.svg Assets/icons/plus-light.svg Assets/icons/pressure-dark.svg Assets/icons/pressure-light.svg Assets/icons/pulse-dark.svg Assets/icons/pulse-light.svg Assets/icons/rightArrow-dark.svg Assets/icons/rightArrow-light.svg Assets/icons/right-dark.svg Assets/icons/right-light.svg Assets/icons/settings-dark.svg Assets/icons/settings-light.svg Assets/icons/stage3d-dark.svg Assets/icons/stage3d-light.svg Assets/icons/stop-dark.svg Assets/icons/stop-light.svg Assets/icons/sun-dark.svg Assets/icons/sun-light.svg Assets/icons/sunrise-dark.svg Assets/icons/sunrise-light.svg Assets/icons/sunset-dark.svg Assets/icons/sunset-light.svg Assets/icons/thermometer.svg Assets/icons/thermometer-dark.svg Assets/icons/thermometer-light.svg Assets/icons/tooltip.svg Assets/icons/upArrow-dark.svg Assets/icons/upArrow-light.svg Assets/icons/uturnleft-dark.svg Assets/icons/uturnleft-light.svg Assets/icons/uturnright-dark.svg Assets/icons/uturnright-light.svg Assets/icons/weather-dark.svg Assets/icons/weather-few-clouds-dark.svg Assets/icons/weather-few-clouds-light.svg Assets/icons/weather-fog-dark.svg Assets/icons/weather-fog-light.svg Assets/icons/weather-haze-dark.svg Assets/icons/weather-haze-light.svg Assets/icons/weather-icy-dark.svg Assets/icons/weather-icy-light.svg Assets/icons/weather-light.svg Assets/icons/weather-overcast-dark.svg Assets/icons/weather-overcast-light.svg Assets/icons/weather-showers-dark.svg Assets/icons/weather-showers-light.svg Assets/icons/weather-showers-scattered-dark.svg Assets/icons/weather-showers-scattered-light.svg Assets/icons/weather-sleet-dark.svg Assets/icons/weather-sleet-light.svg Assets/icons/weather-snow-dark.svg Assets/icons/weather-snow-light.svg Assets/icons/weather-storm-dark.svg Assets/icons/weather-storm-light.svg Assets/icons/weather-sunny-dark.svg Assets/icons/weather-sunny-light.svg Assets/icons/weather-sunny-very-few-clouds-dark.svg Assets/icons/weather-sunny-very-few-clouds-light.svg Assets/icons/weather-thundershower-dark.svg Assets/icons/weather-thundershower-light.svg Assets/icons/wifi-dark.svg Assets/icons/wifi-light.svg Assets/icons/wind-dark.svg Assets/icons/wind-light.svg Assets/icons/yellowsun.svg
        RESOURCES Assets/icons/todo-dark.svg Assets/icons/todo-light.svg Assets/icons/album-dark.svg Assets/icons/album-light.svg
        RESOURCES Assets/icons/mono/moon.svg Assets/icons/mono/sunrise.svg Assets/icons/mono/book.svg Assets/icons/mono/image.svg Assets/icons/mono/music.svg Assets/icons/mono/clipboard-list.svg Assets/icons/mono/chevron-right.svg Assets/icons/mono/alarm-clock.svg Assets/icons/mono/check-circle.svg Assets/icons/mono/target.svg Assets/icons/mono/trash.svg Assets/icons/mono/user.svg
        QML_FILES Views/Pages/Dashboard.qml
        QML_FILES Widgets/Page/PageTopBarItem.qml
        QML_FILES Views/LauncherPage.qml
        QML_FILES Widgets/Cards/SceneCard.qml
        QML_FILES Widgets/Cards/ControlCard.qml
        QML_FILES Widgets/Cards/ActivityItemCard.qml
        QML_FILES Widgets/Buttons/NavButton.qml
        QML_FILES Widgets/Buttons/LauncherMenuButton.qml
        QML_FILES Widgets/Cards/DashboardCard.qml
        QML_FILES Views/ClockPage.qml
        QML_FILES Views/Settings.qml
        QML_FILES Views/TodoPage.qml
        QML_FILES Views/AlbumPage.qml
        SOURCES ViewModels/appcontroller.h ViewModels/appcontroller.cpp
        SOURCES Models/datetimemodel.h Models/datetimemodel.cpp
        SOURCES ViewModels/datetimeviewmodel.h ViewModels/datetimeviewmodel.cpp
        QML_FILES Widgets/Clock/DigitalClock.qml
        QML_FILES Widgets/Clock/DateDisplay.qml
        QML_FILES Widgets/Clock/AnalogClock.qml
        QML_FILES Widgets/Clock/AlarmView.qml
        QML_FILES Widgets/Clock/AlarmList.qml
        QML_FILES Widgets/Clock/AlarmCard.qml
        QML_FILES Widgets/Clock/RepeatDaysSelector.qml
        QML_FILES Widgets/Buttons/ModernToggle.qml
        QML_FILES Widgets/Clock/AddAlarmButton.qml
        QML_FILES Widgets/Clock/AddAlarmPopup.qml
        QML_FILES Widgets/Clock/StopWatchView.qml
        QML_FILES Widgets/Clock/StopWatchDisplay.qml
        QML_FILES Widgets/Clock/StopWatchControls.qml
        QML_FILES Widgets/Clock/StopWatchButton.qml
        QML_FILES Widgets/Clock/BottomNavigationBar.qml
        QML_FILES Widgets/Clock/NavigationIcon.qml
        QML_FILES Widgets/Clock/ClockView.qml
        QML_FILES Widgets/Clock/ClockStylePicker.qml
        SOURCES Models/todomodel.h Models/todomodel.cpp
        SOURCES Models/alarmmodel.h Models/alarmmodel.cpp
        SOURCES Models/storageservice.h Models/storageservice.cpp
        SOURCES Models/thememanager.h Models/thememanager.cpp
        SOURCES ViewModels/todoviewmodel.h ViewModels/todoviewmodel.cpp
        SOURCES ViewModels/alarmviewmodel.h ViewModels/alarmviewmodel.cpp
        QML_FILES Widgets/Todo/TodoItem.qml
        QML_FILES Widgets/Todo/TodoInput.qml
        QML_FILES Widgets/Todo/TodoList.qml
        QML_FILES Widgets/Todo/TodoHeader.qml
        QML_FILES Widgets/Todo/TodoPreviewCard.qml
        QML_FILES Widgets/Todo/TodoFilterTabs.qml
        QML_FILES Widgets/Settings/SettingsColumn.qml
        QML_FILES Widgets/Settings/SettingsItem.qml
        QML_FILES Widgets/Settings/ThemeSelector.qml
        QML_FILES Widgets/Clock/NightModeOverlay.qml
        QML_FILES Widgets/Clock/FlashOverlay.qml
        QML_FILES Widgets/Buttons/ActionCard.qml
        QML_FILES Widgets/Common/ThemedIcon.qml
        QML_FILES Widgets/Clock/CountdownOverlay.qml
        QML_FILES Widgets/Clock/ReadingOverlay.qml
        QML_FILES Widgets/Clock/GalleryOverlay.qml
        QML_FILES Widgets/Clock/AmbianceOverlay.qml
        QML_FILES Widgets/Clock/AmbianceGradients.js
        QML_FILES Views/RobotPage.qml
        QML_FILES Widgets/Robot/RobotFace.qml
        QML_FILES Widgets/Robot/ExpressionButton.qml
        QML_FILES Widgets/Robot/ExpressionBar.qml
        QML_FILES Widgets/Robot/RobotSpeechBubble.qml
        QML_FILES Widgets/Robot/RobotExpressions.js
        QML_FILES Widgets/Robot/EveFace.qml
        QML_FILES Widgets/Robot/RobotCharacter.qml
        QML_FILES Widgets/Robot/ExpressionDrawer.qml
        QML_FILES Widgets/Settings/CharacterSelector.qml
        RESOURCES Assets/icons/robot-dark.svg Assets/icons/robot-light.svg Assets/icons/mono/robot.svg
        SOURCES Models/timermodel.h Models/timermodel.cpp
        SOURCES ViewModels/timerviewmodel.h ViewModels/timerviewmodel.cpp
        QML_FILES Widgets/Clock/TimerView.qml
        QML_FILES Widgets/Clock/TimerRing.qml
        QML_FILES Widgets/Clock/TimerDurationPicker.qml
        QML_FILES Widgets/Clock/TimerPresets.qml
        QML_FILES Widgets/Clock/TimerControls.qml
        QML_FILES Widgets/Clock/TimerAlertOverlay.qml
        QML_FILES Widgets/Clock/TimerAlertSound.qml
        RESOURCES Assets/sounds/timer_alert.wav
        SOURCES Models/calculatorhistorymodel.h Models/calculatorhistorymodel.cpp
        SOURCES Models/calculatormodel.h Models/calculatormodel.cpp
        SOURCES ViewModels/calculatorviewmodel.h ViewModels/calculatorviewmodel.cpp
        QML_FILES Views/CalculatorPage.qml
        QML_FILES Widgets/Calculator/CalcButton.qml
        QML_FILES Widgets/Calculator/CalculatorDisplay.qml
        QML_FILES Widgets/Calculator/CalculatorKeypad.qml
        QML_FILES Widgets/Calculator/CalculatorScientificPad.qml
        QML_FILES Widgets/Calculator/CalculatorHistoryPanel.qml
        RESOURCES Assets/icons/calculator-dark.svg Assets/icons/calculator-light.svg Assets/icons/mono/calculator.svg
        SOURCES Models/wifinetworkmodel.h Models/wifinetworkmodel.cpp
        SOURCES Models/wifimanager.h Models/wifimanager.cpp
        QML_FILES Widgets/Wifi/SignalBars.qml
        QML_FILES Widgets/Wifi/WifiStatusButton.qml
        QML_FILES Widgets/Wifi/WifiNetworkRow.qml
        QML_FILES Widgets/Wifi/WifiPopup.qml
        QML_FILES Widgets/Breathing/BreathingOverlay.qml
        QML_FILES Widgets/Breathing/BreathModeButton.qml
        QML_FILES Widgets/Breathing/BreathDotsVisual.qml
        QML_FILES Widgets/Breathing/BreathBoxVisual.qml
        QML_FILES Widgets/Breathing/BreathPetalsVisual.qml
        QML_FILES Widgets/Breathing/BreathingPatterns.js
        RESOURCES Assets/icons/mono/wind.svg Assets/icons/mono/activity.svg
        SOURCES Models/languagemanager.h Models/languagemanager.cpp
        RESOURCES Strings/qmldir
        QML_FILES Strings/BreathingStrings.qml
        QML_FILES Strings/RobotStrings.qml
        QML_FILES Widgets/Settings/LanguageSelector.qml
        QML_FILES Views/GamesPage.qml
        QML_FILES Widgets/Games/GameOverlay.qml
        QML_FILES Widgets/Games/GameShell.qml
        QML_FILES Widgets/Games/GameScenery.qml
        QML_FILES Widgets/Games/GameCard.qml
        QML_FILES Widgets/Games/FlappyGame.qml
        QML_FILES Widgets/Games/RunnerGame.qml
        QML_FILES Widgets/Games/ReflexGame.qml
        QML_FILES Widgets/Games/GameRules.js
        QML_FILES Strings/GameStrings.qml
        RESOURCES Assets/icons/game-dark.svg Assets/icons/game-light.svg Assets/icons/mono/gamepad.svg

)

# Translations. lupdate scans the target's SOURCES, which is where
# qt_add_qml_module put every QML_FILES entry (the .js files included), so the
# whole module is covered without listing anything twice.
#
# No TS_FILES: I18N_TRANSLATED_LANGUAGES above makes Qt derive
#   i18n/NightStand_tr.ts  - the Turkish catalogue
#   i18n/NightStand_en.ts  - plural forms only
# and embed the compiled .qm under qrc :/i18n/ .
#
# This must sit after qt_add_qml_module: without SOURCE_TARGETS the call defers
# itself to the end of the project scope and auto-collects every target in the
# directory tree. Being explicit is worth the placement constraint.
#
# TS_FILE_DIR, not TS_OUTPUT_DIRECTORY: newer Qt accepts both (one is an alias),
# but Qt 6.8 on Raspberry Pi OS only knows TS_FILE_DIR and would read the other
# as a target name.
qt_add_translations(
    TARGETS appNightStand
    SOURCE_TARGETS appNightStand
    TS_FILE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/i18n
    RESOURCE_PREFIX "/i18n"
    IMMEDIATE_CALL
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appNightStand PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appNightStand
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appNightStand
    PRIVATE Qt6::Quick
)
target_link_libraries(appNightStand PRIVATE Qt6::Core)
target_link_libraries(appNightStand PRIVATE Qt6::Core)
target_link_libraries(appNightStand PRIVATE Qt6::Core)
target_link_libraries(appNightStand PRIVATE Qt6::Core)
target_link_libraries(appNightStand PRIVATE Qt6::Core)
target_link_libraries(appNightStand PRIVATE Qt6::Multimedia)
if(TARGET Qt6::QuickShapes)
    target_link_libraries(appNightStand PRIVATE Qt6::QuickShapes)
endif()
target_link_libraries(appNightStand PRIVATE Qt6::VirtualKeyboard)

include(GNUInstallDirs)
install(TARGETS appNightStand
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
