import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"
import "../Widgets/Todo"

Rectangle {
    id: todopage
    anchors.fill: parent
    color: UiStyle.baseColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 60
        spacing: 15

        // Header with stats
        TodoHeader {
            Layout.fillWidth: true
            totalCount: todoViewModel.totalCount
            completedCount: todoViewModel.completedCount
            pendingCount: todoViewModel.pendingCount
            onClearCompleted: todoViewModel.clearCompleted()
        }

        // Input for adding new todos
        TodoInput {
            Layout.fillWidth: true
            onAddTodo: (title, description) => {
                todoViewModel.addTodo(title, description)
            }
        }

        // Todo list
        TodoList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: todoViewModel.todoModel
            totalCount: todoViewModel.totalCount
            completedCount: todoViewModel.completedCount

            onToggleCompleted: (id) => todoViewModel.toggleCompleted(id)
            onRemoveTodo: (id) => todoViewModel.removeTodo(id)
            onEditTodo: (id, title, desc) => todoViewModel.updateTodo(id, title, desc)
        }
    }
}
