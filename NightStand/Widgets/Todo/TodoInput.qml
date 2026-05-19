import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: todoInput

    signal addTodo(string title, string description)

    property bool expanded: false
    readonly property int collapsedHeight: 76
    readonly property int expandedHeight: 168

    height: expanded ? expandedHeight : collapsedHeight
    radius: 18
    color: UiStyle.cardPanelColor

    Behavior on height {
        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }

    function submit() {
        if (titleField.text.trim().length > 0) {
            todoInput.addTodo(titleField.text.trim(), descriptionField.text.trim())
            titleField.text = ""
            descriptionField.text = ""
            todoInput.expanded = false
            titleField.focus = false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // Top row: title input + main button
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            spacing: 10

            // Title field
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: UiStyle.innerCardColor
                border.color: titleField.activeFocus ? UiStyle.headerColor : UiStyle.transparent
                border.width: 2

                Behavior on border.color { ColorAnimation { duration: 200 } }

                TextField {
                    id: titleField
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    placeholderText: qsTr("Yeni görev ekle...")
                    placeholderTextColor: UiStyle.subtextColor
                    color: UiStyle.textColor
                    font.pixelSize: 16
                    selectByMouse: true
                    background: Item {}

                    onActiveFocusChanged: {
                        if (activeFocus && !todoInput.expanded) {
                            todoInput.expanded = true
                        }
                    }

                    Keys.onReturnPressed: todoInput.submit()
                    Keys.onEnterPressed: todoInput.submit()
                    Keys.onEscapePressed: {
                        titleField.text = ""
                        descriptionField.text = ""
                        todoInput.expanded = false
                        titleField.focus = false
                    }
                }
            }

            // Toggle/Add button
            Rectangle {
                id: mainButton
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                radius: 14
                readonly property bool isSubmit: titleField.text.trim().length > 0
                color: mainMouseArea.pressed
                       ? Qt.darker(isSubmit ? UiStyle.buttonProgress : UiStyle.innerCardColor, 1.2)
                       : (isSubmit ? UiStyle.buttonProgress : UiStyle.innerCardColor)

                scale: mainMouseArea.pressed ? 0.94 : 1.0

                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                Text {
                    anchors.centerIn: parent
                    text: mainButton.isSubmit ? "✓" : "+"
                    font.pixelSize: mainButton.isSubmit ? 26 : 32
                    font.bold: true
                    color: mainButton.isSubmit ? UiStyle.white : UiStyle.headerColor
                    rotation: todoInput.expanded && !mainButton.isSubmit ? 45 : 0

                    Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    id: mainMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (mainButton.isSubmit) {
                            todoInput.submit()
                        } else {
                            todoInput.expanded = !todoInput.expanded
                            if (todoInput.expanded) {
                                titleField.forceActiveFocus()
                            } else {
                                titleField.focus = false
                            }
                        }
                    }
                }
            }
        }

        // Description row (visible when expanded)
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            opacity: todoInput.expanded ? 1 : 0
            visible: opacity > 0
            clip: true

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            RowLayout {
                anchors.fill: parent
                spacing: 10

                // Description field
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: 12
                    color: UiStyle.innerCardColor
                    border.color: descriptionField.activeFocus ? UiStyle.headerColor : UiStyle.transparent
                    border.width: 2

                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    TextField {
                        id: descriptionField
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        verticalAlignment: TextInput.AlignVCenter
                        placeholderText: qsTr("Açıklama (opsiyonel)...")
                        placeholderTextColor: UiStyle.subtextColor
                        color: UiStyle.textColor
                        font.pixelSize: 14
                        selectByMouse: true
                        background: Item {}

                        Keys.onReturnPressed: todoInput.submit()
                        Keys.onEnterPressed: todoInput.submit()
                        Keys.onEscapePressed: {
                            titleField.text = ""
                            descriptionField.text = ""
                            todoInput.expanded = false
                        }
                    }
                }

                // Cancel button
                Rectangle {
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    radius: 14
                    color: cancelArea.pressed
                           ? Qt.darker(UiStyle.innerCardColor, 1.3)
                           : UiStyle.innerCardColor

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 18
                        font.bold: true
                        color: UiStyle.subtextColor
                    }

                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            titleField.text = ""
                            descriptionField.text = ""
                            todoInput.expanded = false
                            titleField.focus = false
                        }
                    }
                }
            }
        }
    }
}
