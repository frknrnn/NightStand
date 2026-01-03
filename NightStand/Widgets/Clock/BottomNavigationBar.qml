import QtQuick
import QtQuick.Layouts
import "../../Style"
import "../../Widgets/Clock"

Rectangle {
    id: navigationBar

    property int currentPage: 0

    signal pageClicked(int pageIndex)

    color: UiStyle.cardPanelColor

    RowLayout {
        anchors.centerIn: parent
        spacing: 60

        NavigationIcon {
            iconText: "🕐"
            isActive: currentPage === 0
            onClicked: navigationBar.pageClicked(0)
        }

        NavigationIcon {
            iconText: "⏰"
            isActive: currentPage === 1
            onClicked: navigationBar.pageClicked(1)
        }

        NavigationIcon {
            iconText: "⏱️"
            isActive: currentPage === 2
            onClicked: navigationBar.pageClicked(2)
        }
    }
}
