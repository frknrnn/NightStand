import QtQuick
import QtQuick.Layouts
import "../../Style"

ColumnLayout {
    id: presetColumn

    property var presetModel: []

    signal presetClicked(int index)

    spacing: 12

    Text {
        Layout.fillWidth: true
        text: "Quick set"
        font.pixelSize: 16
        font.bold: true
        color: UiStyle.subtextColor
    }

    Repeater {
        model: presetColumn.presetModel

        delegate: Rectangle {
            id: pill

            required property int index
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 64
            radius: height / 2
            color: pillArea.pressed ? UiStyle.roundButtonColor : UiStyle.innerCardColor
            border.width: 1
            border.color: pillArea.pressed ? UiStyle.headerColor : UiStyle.roundButtonColor
            scale: pillArea.pressed ? 0.96 : 1.0

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            Behavior on border.color {
                ColorAnimation { duration: 150 }
            }
            Behavior on scale {
                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: pill.modelData.label
                font.pixelSize: 20
                font.bold: true
                color: UiStyle.textColor
            }

            MouseArea {
                id: pillArea
                anchors.fill: parent
                onClicked: presetColumn.presetClicked(pill.index)
            }
        }
    }

    Item { Layout.fillHeight: true }
}
