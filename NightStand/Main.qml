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
                                if (createdPage.status !== Component.Ready)
                                    createdPage = Qt.createComponent(fallback)
                                stackView.push(createdPage)
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

}
