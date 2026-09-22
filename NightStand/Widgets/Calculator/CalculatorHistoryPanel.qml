import QtQuick
import QtQuick.Layouts
import "../Common"
import "../../Style"

// Soldaki işlem geçmişi kartı. En yeni işlem en üstte; bir satıra dokunmak
// sonucu ekrana geri yükler.
Rectangle {
    id: panel

    property var entries: null
    property int entryCount: 0

    signal entryClicked(int index)
    signal clearRequested()

    radius: 20
    color: UiStyle.cardPanelColor

    Behavior on color { ColorAnimation { duration: 250 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: qsTr("History")
                font.pixelSize: 16
                font.bold: true
                color: UiStyle.headerColor

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 12
                color: clearArea.pressed ? UiStyle.innerCardColor : UiStyle.transparent
                scale: clearArea.pressed ? 0.92 : 1.0
                visible: panel.entryCount > 0

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }

                ThemedIcon {
                    anchors.centerIn: parent
                    source: UiStyle.monoIconPath("trash")
                    size: 18
                    color: UiStyle.red
                }

                MouseArea {
                    id: clearArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panel.clearRequested()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: UiStyle.roundButtonColor
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: historyList
                anchors.fill: parent
                clip: true
                spacing: 4
                model: panel.entries
                boundsBehavior: Flickable.StopAtBounds

                add: Transition {
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220 }
                        NumberAnimation {
                            property: "x"; from: -20; to: 0
                            duration: 220; easing.type: Easing.OutCubic
                        }
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "x,y"; duration: 220; easing.type: Easing.OutCubic
                    }
                }

                delegate: Rectangle {
                    id: row

                    required property int index
                    required property string expression
                    required property string result

                    width: historyList.width
                    height: 58
                    radius: 12
                    color: rowArea.pressed ? UiStyle.innerCardColor : UiStyle.transparent
                    scale: rowArea.pressed ? 0.97 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

                    Column {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 8
                        spacing: 2

                        Text {
                            width: parent.width
                            text: row.expression
                            font.pixelSize: 12
                            color: UiStyle.subtextColor
                            elide: Text.ElideLeft
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            width: parent.width
                            text: row.result
                            font.pixelSize: 21
                            font.bold: true
                            color: UiStyle.textColor
                            elide: Text.ElideLeft
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panel.entryClicked(row.index)
                    }
                }
            }

            // Boş durum
            Column {
                anchors.centerIn: parent
                spacing: 10
                visible: panel.entryCount === 0

                ThemedIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: UiStyle.monoIconPath("calculator")
                    size: 44
                    color: UiStyle.subtextColor
                    opacity: 0.6
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("No calculations yet")
                    font.pixelSize: 14
                    color: UiStyle.subtextColor
                }
            }
        }
    }
}
