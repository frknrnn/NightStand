import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: settingsColumn

    property string title: ""
    property alias content: contentArea.data

    radius: 12
    color: UiStyle.cardPanelColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Column Header
        Text {
            Layout.fillWidth: true
            text: settingsColumn.title
            font.pixelSize: 18
            font.bold: true
            color: UiStyle.headerColor
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: UiStyle.subtextColor
            opacity: 0.3
        }

        // Content Area
        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
