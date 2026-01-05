import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: todoItem

    property int todoId: 0
    property string title: ""
    property string description: ""
    property bool completed: false

    signal toggleCompleted(int id)
    signal removeTodo(int id)
    signal editTodo(int id, string title, string description)

    height: contentLayout.implicitHeight + 24
    radius: 12
    color: UiStyle.cardPanelColor
    border.color: completed ? UiStyle.buttonProgress : "transparent"
    border.width: completed ? 2 : 0

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Checkbox
        Rectangle {
            id: checkbox
            width: 28
            height: 28
            radius: 14
            color: completed ? UiStyle.buttonProgress : "transparent"
            border.color: completed ? UiStyle.buttonProgress : UiStyle.subtextColor
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 16
                font.bold: true
                color: UiStyle.white
                visible: completed
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: todoItem.toggleCompleted(todoItem.todoId)
            }
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: todoItem.title
                font.pixelSize: 16
                font.bold: true
                font.strikeout: completed
                color: completed ? UiStyle.subtextColor : UiStyle.textColor
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: todoItem.description
                font.pixelSize: 12
                font.strikeout: completed
                color: UiStyle.subtextColor
                elide: Text.ElideRight
                visible: todoItem.description.length > 0
            }
        }

        // Delete button
        Rectangle {
            id: deleteButton
            width: 36
            height: 36
            radius: 18
            color: deleteMouseArea.containsMouse ? UiStyle.red : UiStyle.roundButtonColor

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.pixelSize: 16
                font.bold: true
                color: UiStyle.white
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: todoItem.removeTodo(todoItem.todoId)
            }
        }
    }
}
