// DashboardCard.qml
import QtQuick 2.15
import "../../Style"

Rectangle {
    color: UiStyle.innerCardColor
    radius: 16
    default property alias content: container.data
    Item {
        id: container
        anchors.fill: parent
    }
}
