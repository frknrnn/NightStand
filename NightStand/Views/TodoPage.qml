import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"
import "../Widgets/Todo"

Rectangle {
    id: todopage
    anchors.fill: parent
    color: UiStyle.baseColor

    property int filterMode: 0  // 0=All, 1=Active, 2=Completed

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 60
        anchors.bottomMargin: 16
        spacing: 14

        TodoHeader {
            Layout.fillWidth: true
            totalCount: todoViewModel.totalCount
            completedCount: todoViewModel.completedCount
            pendingCount: todoViewModel.pendingCount
            onClearCompleted: todoViewModel.clearCompleted()
        }

        TodoInput {
            Layout.fillWidth: true
            onAddTodo: (title, description) => {
                todoViewModel.addTodo(title, description)
            }
        }

        TodoFilterTabs {
            Layout.fillWidth: true
            selectedIndex: todopage.filterMode
            totalCount: todoViewModel.totalCount
            activeCount: todoViewModel.pendingCount
            completedCount: todoViewModel.completedCount
            onFilterChanged: (index) => todopage.filterMode = index
        }

        TodoList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: todoViewModel.todoModel
            filterMode: todopage.filterMode
            totalCount: todoViewModel.totalCount
            activeCount: todoViewModel.pendingCount
            completedCount: todoViewModel.completedCount

            onToggleCompleted: (id) => todoViewModel.toggleCompleted(id)
            onRemoveTodo: (id) => todoViewModel.removeTodo(id)
            onEditTodo: (id, title, desc) => todoViewModel.updateTodo(id, title, desc)
        }
    }
}
