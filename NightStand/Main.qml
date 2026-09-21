import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Shapes
import QtQuick.VirtualKeyboard 2.15
import "Views/Pages"
import "Views"
import "Widgets"
import "Widgets/Page"
import "Widgets/Clock"

QQC2.ApplicationWindow {
    width: 1024
    height: 600
    visible: true
    title: qsTr("NightStand PFT")
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visibility: Qt.WindowMaximized

    Rectangle{
        id:base
        anchors.fill: parent
        anchors.centerIn:parent

        QQC2.StackView{
            id:stackView
            anchors.fill:parent
            focus:true
            initialItem: LauncherPage {
                onLaunched: (title, page, fallback) => {
                                var createdPage = Qt.createComponent(page)
                                if (createdPage.status !== Component.Ready && fallback !== "")
                                    createdPage = Qt.createComponent(fallback)
                                if (createdPage.status === Component.Ready)
                                    stackView.push(createdPage)
                                else
                                    console.warn("LauncherPage: sayfa yüklenemedi", page, "-", createdPage.errorString())
                                //header.title = title
                            }
            }
        }
    }

    PageTopBarItem {
        id: header
        anchors.top: parent.top
        width: parent.width
        //title: ""
        enabled: stackView.depth > 1
        onBackClicked: stackView.pop()
    }

    // Night Mode Overlay - shows only clock and date on black background
    NightModeOverlay {
        id: nightModeOverlay
        anchors.fill: parent
    }

    // Flash Overlay - white screen for flash/torch mode
    FlashOverlay {
        id: flashOverlay
        anchors.fill: parent
    }

    // Reading Overlay - full-screen book reading mode with brightness + warm palette
    ReadingOverlay {
        id: readingOverlay
        anchors.fill: parent
    }

    // Gallery Overlay - animated gradient slideshow
    GalleryOverlay {
        id: galleryOverlay
        anchors.fill: parent
    }

    // Timer alert - the countdown keeps running across pages, so the alert
    // has to be able to fire from anywhere. Window level, above every overlay.
    TimerAlertOverlay {
        id: timerAlertOverlay
        anchors.fill: parent
    }

    // Sanal klavye. QT_IM_MODULE main.cpp'de ayarlı ve VirtualKeyboard yukarıda
    // import ediliyordu, ama ekrana bir InputPanel yerleştirilmediği sürece
    // klavye hiç görünmüyor - dokunmatik ekranda hiçbir metin alanı yazılamıyordu.
    //
    // parent: Overlay.overlay olmak ZORUNDA: Popup'lar ayrı bir overlay
    // katmanında çizilir, ApplicationWindow'un normal çocuğu olsaydı klavye
    // Wi-Fi popup'ının altında kalırdı.
    InputPanel {
        id: inputPanel
        parent: QQC2.Overlay.overlay
        z: 99

        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        y: active ? parent.height - height : parent.height
        visible: active

        Behavior on y {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
    }
}
