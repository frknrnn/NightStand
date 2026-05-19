import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Item {
    id: todoItem

    property int todoId: 0
    property string title: ""
    property string description: ""
    property bool completed: false

    property bool editing: false

    signal toggleCompleted(int id)
    signal removeTodo(int id)
    signal editTodo(int id, string title, string description)

    height: editing
            ? Math.max(180, editLayout.implicitHeight + 28)
            : (descriptionText.visible ? 96 : 80)
    clip: true

    Behavior on height {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    // Delete background (revealed by swipe)
    Rectangle {
        id: deleteBackground
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        radius: 16
        color: UiStyle.red

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 24
            spacing: 10

            Text {
                text: qsTr("Sil")
                font.pixelSize: 18
                font.bold: true
                color: UiStyle.white
                opacity: Math.min(1, -contentCard.x / 90)
            }

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: UiStyle.white
                opacity: Math.min(1, -contentCard.x / 90)

                Text {
                    anchors.centerIn: parent
                    text: "🗑"
                    font.pixelSize: 20
                }
            }
        }
    }

    // Main content card (swipeable)
    Rectangle {
        id: contentCard
        width: parent.width
        height: parent.height - 8
        y: 4
        radius: 16
        color: UiStyle.cardPanelColor
        border.color: todoItem.completed ? UiStyle.buttonProgress : UiStyle.transparent
        border.width: todoItem.completed ? 2 : 0

        scale: pressBlocker.pressed && !todoItem.editing ? 0.985 : 1.0

        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on border.color { ColorAnimation { duration: 250 } }
        Behavior on border.width { NumberAnimation { duration: 250 } }
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

        // ---- VIEW MODE LAYOUT ----
        RowLayout {
            id: viewLayout
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16
            visible: !todoItem.editing
            opacity: visible ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 150 } }

            // Checkbox
            Rectangle {
                id: checkbox
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 22
                color: todoItem.completed ? UiStyle.buttonProgress : UiStyle.transparent
                border.color: todoItem.completed ? UiStyle.buttonProgress : UiStyle.subtextColor
                border.width: 2.5

                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on border.color { ColorAnimation { duration: 250 } }

                Text {
                    id: checkMark
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 22
                    font.bold: true
                    color: UiStyle.white
                    scale: todoItem.completed ? 1 : 0
                    opacity: todoItem.completed ? 1 : 0

                    Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }

            // Content
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    spacing: 4

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: titleText.implicitHeight

                        Text {
                            id: titleText
                            anchors.left: parent.left
                            anchors.right: parent.right
                            text: todoItem.title
                            font.pixelSize: 17
                            font.bold: true
                            color: todoItem.completed ? UiStyle.subtextColor : UiStyle.textColor
                            elide: Text.ElideRight

                            Behavior on color { ColorAnimation { duration: 250 } }
                        }

                        // Animated strikethrough line
                        Rectangle {
                            height: 2
                            radius: 1
                            color: UiStyle.subtextColor
                            anchors.left: titleText.left
                            anchors.verticalCenter: titleText.verticalCenter
                            width: todoItem.completed
                                   ? Math.min(titleText.contentWidth, titleText.width)
                                   : 0

                            Behavior on width { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
                        }
                    }

                    Text {
                        id: descriptionText
                        Layout.fillWidth: true
                        text: todoItem.description
                        font.pixelSize: 13
                        color: UiStyle.subtextColor
                        elide: Text.ElideRight
                        visible: todoItem.description.length > 0
                        opacity: todoItem.completed ? 0.55 : 1.0

                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }
                }
            }

            // Edit button (clicks handled by pressBlocker via hit-testing)
            Rectangle {
                id: editButton
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 12
                color: UiStyle.transparent

                Text {
                    anchors.centerIn: parent
                    text: "✎"
                    font.pixelSize: 20
                    color: UiStyle.subtextColor
                }
            }
        }

        // ---- EDIT MODE LAYOUT ----
        ColumnLayout {
            id: editLayout
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8
            visible: todoItem.editing
            opacity: visible ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 200 } }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 10
                color: UiStyle.innerCardColor
                border.color: editTitleField.activeFocus ? UiStyle.headerColor : UiStyle.transparent
                border.width: 2

                Behavior on border.color { ColorAnimation { duration: 200 } }

                TextField {
                    id: editTitleField
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    placeholderText: qsTr("Başlık")
                    placeholderTextColor: UiStyle.subtextColor
                    color: UiStyle.textColor
                    font.pixelSize: 16
                    font.bold: true
                    selectByMouse: true
                    background: Item {}

                    Keys.onReturnPressed: saveEdit()
                    Keys.onEnterPressed: saveEdit()
                    Keys.onEscapePressed: cancelEdit()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 10
                color: UiStyle.innerCardColor
                border.color: editDescField.activeFocus ? UiStyle.headerColor : UiStyle.transparent
                border.width: 2

                Behavior on border.color { ColorAnimation { duration: 200 } }

                TextField {
                    id: editDescField
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    placeholderText: qsTr("Açıklama")
                    placeholderTextColor: UiStyle.subtextColor
                    color: UiStyle.textColor
                    font.pixelSize: 14
                    selectByMouse: true
                    background: Item {}

                    Keys.onReturnPressed: saveEdit()
                    Keys.onEnterPressed: saveEdit()
                    Keys.onEscapePressed: cancelEdit()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 44
                    radius: 12
                    color: cancelEditArea.pressed
                           ? Qt.darker(UiStyle.innerCardColor, 1.25)
                           : UiStyle.innerCardColor

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Vazgeç")
                        font.pixelSize: 14
                        color: UiStyle.subtextColor
                    }

                    MouseArea {
                        id: cancelEditArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cancelEdit()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 44
                    radius: 12
                    readonly property bool canSave: editTitleField.text.trim().length > 0
                    color: saveEditArea.pressed
                           ? Qt.darker(UiStyle.buttonProgress, 1.2)
                           : (canSave ? UiStyle.buttonProgress : Qt.darker(UiStyle.buttonProgress, 1.4))
                    opacity: canSave ? 1 : 0.5

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Kaydet")
                        font.pixelSize: 14
                        font.bold: true
                        color: UiStyle.white
                    }

                    MouseArea {
                        id: saveEditArea
                        anchors.fill: parent
                        enabled: parent.canSave
                        cursorShape: Qt.PointingHandCursor
                        onClicked: saveEdit()
                    }
                }
            }
        }

        // Press feedback covering the card (won't intercept double clicks on edit button area)
        MouseArea {
            id: pressBlocker
            anchors.fill: parent
            propagateComposedEvents: true
            preventStealing: false
            drag.target: contentCard
            drag.axis: Drag.XAxis
            drag.minimumX: -160
            drag.maximumX: 0
            enabled: !todoItem.editing
            cursorShape: Qt.PointingHandCursor

            property point pressPoint: Qt.point(0, 0)
            property bool tapCandidate: false

            onPressed: (mouse) => {
                pressPoint = Qt.point(mouse.x, mouse.y)
                tapCandidate = true
            }

            onPositionChanged: (mouse) => {
                if (Math.abs(mouse.x - pressPoint.x) > 6 || Math.abs(mouse.y - pressPoint.y) > 6) {
                    tapCandidate = false
                }
            }

            onReleased: (mouse) => {
                if (contentCard.x < -100) {
                    deleteAnimation.start()
                    return
                }
                if (contentCard.x < 0) {
                    contentCard.x = 0
                    return
                }

                if (tapCandidate) {
                    // Convert hit to checkbox / edit if those areas; otherwise toggle complete
                    var p = mapToItem(checkbox, mouse.x, mouse.y)
                    if (p.x >= 0 && p.x <= checkbox.width && p.y >= 0 && p.y <= checkbox.height) {
                        todoItem.toggleCompleted(todoItem.todoId)
                        return
                    }
                    var pe = mapToItem(editButton, mouse.x, mouse.y)
                    if (pe.x >= 0 && pe.x <= editButton.width && pe.y >= 0 && pe.y <= editButton.height) {
                        editTitleField.text = todoItem.title
                        editDescField.text = todoItem.description
                        todoItem.editing = true
                        editTitleField.forceActiveFocus()
                        return
                    }
                    todoItem.toggleCompleted(todoItem.todoId)
                }
            }
        }
    }

    function saveEdit() {
        var newTitle = editTitleField.text.trim()
        if (newTitle.length === 0) return
        todoItem.editTodo(todoItem.todoId, newTitle, editDescField.text.trim())
        todoItem.editing = false
    }

    function cancelEdit() {
        todoItem.editing = false
    }

    // Delete animation sequence
    SequentialAnimation {
        id: deleteAnimation

        ParallelAnimation {
            NumberAnimation {
                target: contentCard
                property: "x"
                to: -todoItem.width
                duration: 240
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: contentCard
                property: "opacity"
                to: 0
                duration: 240
            }
        }

        NumberAnimation {
            target: todoItem
            property: "height"
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }

        ScriptAction {
            script: todoItem.removeTodo(todoItem.todoId)
        }
    }
}
