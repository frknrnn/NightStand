import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: todoHeader

    property int totalCount: 0
    property int completedCount: 0
    property int pendingCount: 0

    signal clearCompleted()

    height: 70
    radius: 12
    color: UiStyle.cardPanelColor

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 20

        // Stats
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: qsTr("Todo List")
                font.pixelSize: 20
                font.bold: true
                color: UiStyle.textColor
            }

            RowLayout {
                spacing: 15

                Text {
                    text: "📋 " + totalCount + qsTr(" Total")
                    font.pixelSize: 12
                    color: UiStyle.subtextColor
                }

                Text {
                    text: "✓ " + completedCount + qsTr(" Completed")
                    font.pixelSize: 12
                    color: UiStyle.buttonProgress
                }

                Text {
                    text: "⏳ " + pendingCount + qsTr(" Pending")
                    font.pixelSize: 12
                    color: UiStyle.menuTextColor
                }
            }
        }

        // Clear completed button
        Rectangle {
            id: clearButton
            width: 140
            height: 40
            radius: 8
            color: clearMouseArea.containsMouse ? Qt.darker(UiStyle.red, 1.1) : UiStyle.roundButtonColor
            visible: completedCount > 0

            Text {
                anchors.centerIn: parent
                text: qsTr("Clear Completed")
                font.pixelSize: 12
                color: UiStyle.white
            }

            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: todoHeader.clearCompleted()
            }
        }
    }
}
