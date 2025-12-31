// ActivityItem.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15

RowLayout {
    property string text: ""
    property string time: ""

    spacing: 10

    Rectangle {
        width: 30
        height: 30
        radius: 15
        color: "#2a3f5f"

        Text {
            anchors.centerIn: parent
            text: "👤"
            font.pixelSize: 14
        }
    }

    ColumnLayout {
        spacing: 2

        Text {
            text: parent.parent.text
            font.pixelSize: 12
            color: "white"
        }

        Text {
            text: parent.parent.time
            font.pixelSize: 10
            color: "#7a8fa8"
        }
    }
}
