import QtQuick
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: navigationBar

    property int currentPage: 0

    signal pageClicked(int pageIndex)

    color: "transparent"

    RowLayout {
        anchors.centerIn: parent
        spacing: 40

        NavigationIcon {
            labelText: qsTr("Clock")
            isActive: currentPage === 0
            onClicked: navigationBar.pageClicked(0)
        }

        NavigationIcon {
            labelText: qsTr("Alarm")
            isActive: currentPage === 1
            onClicked: navigationBar.pageClicked(1)
        }

        NavigationIcon {
            labelText: qsTr("Timer")
            isActive: currentPage === 2
            onClicked: navigationBar.pageClicked(2)
        }

        NavigationIcon {
            labelText: qsTr("Stopwatch")
            isActive: currentPage === 3
            onClicked: navigationBar.pageClicked(3)
        }
    }
}
