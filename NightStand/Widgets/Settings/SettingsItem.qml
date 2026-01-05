import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: settingsItem

    property string label: ""
    property string description: ""
    property alias controlContent: controlArea.data

    height: 60
    radius: 8
    color: UiStyle.innerCardColor

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Label and description
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: settingsItem.label
                font.pixelSize: 14
                font.bold: true
                color: UiStyle.textColor
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: settingsItem.description
                font.pixelSize: 11
                color: UiStyle.subtextColor
                elide: Text.ElideRight
                visible: settingsItem.description.length > 0
            }
        }

        // Control area (for switches, buttons, etc.)
        Item {
            id: controlArea
            Layout.preferredWidth: 120
            Layout.fillHeight: true
        }
    }
}
