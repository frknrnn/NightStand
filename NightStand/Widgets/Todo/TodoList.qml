import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Common"
import "../../Style"

Item {
    id: todoList

    property alias model: listView.model
    // 0 = all, 1 = active, 2 = completed
    property int filterMode: 0
    property int totalCount: 0
    property int activeCount: 0
    property int completedCount: 0

    signal toggleCompleted(int id)
    signal removeTodo(int id)
    signal editTodo(int id, string title, string description)

    readonly property int visibleCount: {
        if (filterMode === 1) return activeCount
        if (filterMode === 2) return completedCount
        return totalCount
    }

    ListView {
        id: listView
        anchors.fill: parent
        spacing: 12
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        // Smooth transitions
        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 320; easing.type: Easing.OutCubic }
                NumberAnimation { property: "y"; from: 0; duration: 320; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale"; from: 0.85; to: 1.0; duration: 320; easing.type: Easing.OutCubic }
            }
        }

        displaced: Transition {
            NumberAnimation { properties: "y"; duration: 280; easing.type: Easing.OutCubic }
        }

        remove: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: 200 }
        }

        delegate: Item {
            id: delegateWrap
            width: ListView.view.width

            readonly property bool passesFilter:
                todoList.filterMode === 0 ||
                (todoList.filterMode === 1 && !model.completed) ||
                (todoList.filterMode === 2 && model.completed)

            height: passesFilter ? itemImpl.height : 0
            opacity: passesFilter ? 1 : 0
            visible: opacity > 0
            clip: true

            Behavior on height { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            TodoItem {
                id: itemImpl
                width: parent.width

                todoId: model.todoId
                title: model.title
                description: model.description
                completed: model.completed

                onToggleCompleted: (id) => todoList.toggleCompleted(id)
                onRemoveTodo: (id) => todoList.removeTodo(id)
                onEditTodo: (id, title, desc) => todoList.editTodo(id, title, desc)
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 8
        }

        // Empty state
        Item {
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: emptyContent.implicitHeight
            visible: todoList.visibleCount === 0
            opacity: visible ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 300 } }

            ColumnLayout {
                id: emptyContent
                anchors.centerIn: parent
                width: parent.width
                spacing: 14

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 96
                    radius: 48
                    color: UiStyle.cardPanelColor

                    ThemedIcon {
                        anchors.centerIn: parent
                        size: 44
                        color: UiStyle.subtextColor
                        source: {
                            if (todoList.totalCount === 0) return UiStyle.monoIconPath("clipboard-list")
                            if (todoList.filterMode === 1) return UiStyle.monoIconPath("check-circle")
                            if (todoList.filterMode === 2) return UiStyle.monoIconPath("target")
                            return UiStyle.monoIconPath("clipboard-list")
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        if (todoList.totalCount === 0) return qsTr("Henüz görev yok")
                        if (todoList.filterMode === 1) return qsTr("Tüm görevler tamamlandı")
                        if (todoList.filterMode === 2) return qsTr("Tamamlanan görev yok")
                        return qsTr("Henüz görev yok")
                    }
                    font.pixelSize: 20
                    font.bold: true
                    color: UiStyle.textColor
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    text: {
                        if (todoList.totalCount === 0) return qsTr("Yukarıdan yeni bir görev ekleyerek başla")
                        if (todoList.filterMode === 1) return qsTr("Harika iş! Yeni bir görev eklemek ister misin?")
                        if (todoList.filterMode === 2) return qsTr("Tamamlanan görevler burada görünecek")
                        return ""
                    }
                    font.pixelSize: 14
                    color: UiStyle.subtextColor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
