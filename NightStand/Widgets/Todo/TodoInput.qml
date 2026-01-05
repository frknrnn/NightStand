import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: todoInput

    signal addTodo(string title, string description)

    height: 120
    radius: 12
    color: UiStyle.cardPanelColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Title input
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: UiStyle.innerCardColor
            border.color: titleField.activeFocus ? UiStyle.buttonProgress : "transparent"
            border.width: titleField.activeFocus ? 2 : 0

            TextField {
                id: titleField
                anchors.fill: parent
                anchors.margins: 8
                placeholderText: qsTr("New todo title...")
                placeholderTextColor: UiStyle.subtextColor
                color: UiStyle.textColor
                font.pixelSize: 14
                background: Item {}

                Keys.onReturnPressed: {
                    if (titleField.text.trim().length > 0) {
                        todoInput.addTodo(titleField.text, descriptionField.text)
                        titleField.text = ""
                        descriptionField.text = ""
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Description input
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: UiStyle.innerCardColor
                border.color: descriptionField.activeFocus ? UiStyle.buttonProgress : "transparent"
                border.width: descriptionField.activeFocus ? 2 : 0

                TextField {
                    id: descriptionField
                    anchors.fill: parent
                    anchors.margins: 8
                    placeholderText: qsTr("Description (optional)...")
                    placeholderTextColor: UiStyle.subtextColor
                    color: UiStyle.textColor
                    font.pixelSize: 12
                    background: Item {}

                    Keys.onReturnPressed: {
                        if (titleField.text.trim().length > 0) {
                            todoInput.addTodo(titleField.text, descriptionField.text)
                            titleField.text = ""
                            descriptionField.text = ""
                        }
                    }
                }
            }

            // Add button
            Rectangle {
                id: addButton
                width: 80
                height: 40
                radius: 8
                color: addMouseArea.containsMouse ? Qt.darker(UiStyle.buttonProgress, 1.1) : UiStyle.buttonProgress

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Add")
                    font.pixelSize: 14
                    font.bold: true
                    color: UiStyle.white
                }

                MouseArea {
                    id: addMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (titleField.text.trim().length > 0) {
                            todoInput.addTodo(titleField.text, descriptionField.text)
                            titleField.text = ""
                            descriptionField.text = ""
                        }
                    }
                }
            }
        }
    }
}
