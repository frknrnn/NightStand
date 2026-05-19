import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: todoHeader

    property int totalCount: 0
    property int completedCount: 0
    property int pendingCount: 0

    readonly property real progress: totalCount > 0 ? completedCount / totalCount : 0
    readonly property int progressPercent: Math.round(progress * 100)

    signal clearCompleted()

    height: 110
    radius: 18
    color: UiStyle.cardPanelColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: qsTr("Görevler")
                    font.pixelSize: 26
                    font.bold: true
                    color: UiStyle.textColor
                }

                RowLayout {
                    spacing: 14

                    AnimatedCounter {
                        value: todoHeader.totalCount
                        label: qsTr("toplam")
                        valueColor: UiStyle.textColor
                    }

                    Rectangle {
                        width: 4; height: 4; radius: 2
                        color: UiStyle.subtextColor
                        opacity: 0.6
                    }

                    AnimatedCounter {
                        value: todoHeader.completedCount
                        label: qsTr("tamamlandı")
                        valueColor: UiStyle.buttonProgress
                    }

                    Rectangle {
                        width: 4; height: 4; radius: 2
                        color: UiStyle.subtextColor
                        opacity: 0.6
                    }

                    AnimatedCounter {
                        value: todoHeader.pendingCount
                        label: qsTr("bekleyen")
                        valueColor: UiStyle.menuTextColor
                    }
                }
            }

            // Animated progress percentage badge
            Rectangle {
                Layout.preferredWidth: 78
                Layout.preferredHeight: 58
                radius: 14
                color: UiStyle.innerCardColor

                Text {
                    id: percentText
                    anchors.centerIn: parent
                    text: todoHeader.progressPercent + "%"
                    font.pixelSize: 22
                    font.bold: true
                    color: todoHeader.progress >= 1.0
                           ? UiStyle.buttonProgress
                           : UiStyle.headerColor

                    Behavior on color { ColorAnimation { duration: 250 } }

                    Behavior on text {
                        SequentialAnimation {
                            NumberAnimation { target: percentText; property: "scale"; to: 1.12; duration: 110; easing.type: Easing.OutQuad }
                            NumberAnimation { target: percentText; property: "scale"; to: 1.0;  duration: 130; easing.type: Easing.InQuad }
                        }
                    }
                }
            }

            // Clear completed button
            Rectangle {
                id: clearButton
                Layout.preferredWidth: 58
                Layout.preferredHeight: 58
                radius: 14
                color: clearMouseArea.containsMouse
                       ? Qt.darker(UiStyle.red, 1.15)
                       : (clearMouseArea.pressed ? Qt.darker(UiStyle.red, 1.3) : UiStyle.innerCardColor)
                opacity: todoHeader.completedCount > 0 ? 1 : 0
                visible: opacity > 0
                scale: todoHeader.completedCount > 0 ? 1 : 0.7

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 22
                    font.bold: true
                    color: clearMouseArea.containsMouse ? UiStyle.white : UiStyle.red

                    Behavior on color { ColorAnimation { duration: 150 } }
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

        // Animated progress bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            radius: 4
            color: UiStyle.innerCardColor

            Rectangle {
                id: progressFill
                height: parent.height
                width: parent.width * todoHeader.progress
                radius: parent.radius
                color: todoHeader.progress >= 1.0 ? UiStyle.buttonProgress : UiStyle.headerColor

                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 300 } }

                // Subtle shine effect
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: parent.height
                    radius: parent.radius
                    color: UiStyle.white
                    opacity: 0.25
                    visible: todoHeader.progress > 0 && todoHeader.progress < 1.0
                }
            }
        }
    }

    // Inline counter component
    component AnimatedCounter: Row {
        property int value: 0
        property string label: ""
        property color valueColor: UiStyle.textColor
        spacing: 4

        Text {
            id: valueText
            text: value
            font.pixelSize: 14
            font.bold: true
            color: valueColor
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 200 } }

            Behavior on text {
                SequentialAnimation {
                    NumberAnimation { target: valueText; property: "scale"; to: 1.25; duration: 110; easing.type: Easing.OutQuad }
                    NumberAnimation { target: valueText; property: "scale"; to: 1.0;  duration: 140; easing.type: Easing.InQuad }
                }
            }
        }

        Text {
            text: label
            font.pixelSize: 12
            color: UiStyle.subtextColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
