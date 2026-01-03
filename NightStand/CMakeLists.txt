cmake_minimum_required(VERSION 3.16)

project(NightStand VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.2)

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
        QML_FILES Views/Pages/Dashboard.qml
        QML_FILES Widgets/Page/PageTopBarItem.qml
        QML_FILES Views/LauncherPage.qml
        QML_FILES Widgets/Cards/SceneCard.qml
        QML_FILES Widgets/Cards/ControlCard.qml
        QML_FILES Widgets/Cards/ActivityItemCard.qml
        QML_FILES Widgets/Buttons/NavButton.qml
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
        QML_FILES Widgets/Clock/AlarmItem.qml
        QML_FILES Widgets/Clock/AddAlarmButton.qml
        QML_FILES Widgets/Clock/StopWatchView.qml
        QML_FILES Widgets/Clock/StopWatchDisplay.qml
        QML_FILES Widgets/Clock/StopWatchControls.qml
        QML_FILES Widgets/Clock/StopWatchButton.qml
        QML_FILES Widgets/Clock/BottomNavigationBar.qml
        QML_FILES Widgets/Clock/NavigationIcon.qml
        QML_FILES Widgets/Clock/ClockView.qml

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

include(GNUInstallDirs)
install(TARGETS appNightStand
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
