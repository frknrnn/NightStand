import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Item {
    id: todoList

    property alias model: listView.model
    property int totalCount: 0
    property int completedCount: 0

    signal toggleCompleted(int id)
    signal removeTodo(int id)
    signal editTodo(int id, string title, string description)

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Header stats
        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 12
            color: UiStyle.cardPanelColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                Text {
                    text: qsTr("Total: ") + totalCount
                    font.pixelSize: 14
                    color: UiStyle.textColor
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: qsTr("Completed: ") + completedCount
                    font.pixelSize: 14
                    color: UiStyle.buttonProgress
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: qsTr("Pending: ") + (totalCount - completedCount)
                    font.pixelSize: 14
                    color: UiStyle.menuTextColor
                }
            }
        }

        // List view
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true

            delegate: TodoItem {
                width: listView.width
                todoId: model.todoId
                title: model.title
                description: model.description
                completed: model.completed

                onToggleCompleted: (id) => todoList.toggleCompleted(id)
                onRemoveTodo: (id) => todoList.removeTodo(id)
                onEditTodo: (id, title, desc) => todoList.editTodo(id, title, desc)
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                text: qsTr("No todos yet.\nAdd a new todo!")
                font.pixelSize: 16
                color: UiStyle.subtextColor
                horizontalAlignment: Text.AlignHCenter
                visible: listView.count === 0
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }
}
