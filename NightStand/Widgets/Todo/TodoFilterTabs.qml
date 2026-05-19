import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Style"

Rectangle {
    id: tabs

    // 0 = all, 1 = active, 2 = completed
    property int selectedIndex: 0
    property int totalCount: 0
    property int activeCount: 0
    property int completedCount: 0

    signal filterChanged(int index)

    height: 56
    radius: 14
    color: UiStyle.cardPanelColor

    readonly property var labels: [qsTr("Tümü"), qsTr("Aktif"), qsTr("Tamamlanan")]
    readonly property var counts: [totalCount, activeCount, completedCount]

    Item {
        id: tabRow
        anchors.fill: parent
        anchors.margins: 6

        // Sliding selection indicator
        Rectangle {
            id: indicator
            width: tabRow.width / 3
            height: tabRow.height
            radius: 10
            color: UiStyle.innerCardColor
            x: tabs.selectedIndex * width

            Behavior on x {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 6
                width: 22
                height: 3
                radius: 1.5
                color: UiStyle.headerColor

                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        Row {
            anchors.fill: parent

            Repeater {
                model: 3

                Item {
                    id: tabRoot
                    width: tabRow.width / 3
                    height: tabRow.height

                    readonly property bool isActive: tabs.selectedIndex === index
                    readonly property int tabIndex: index

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: tabs.labels[tabRoot.tabIndex]
                            font.pixelSize: 15
                            font.bold: tabRoot.isActive
                            color: tabRoot.isActive ? UiStyle.headerColor : UiStyle.subtextColor

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Rectangle {
                            Layout.preferredWidth: countText.implicitWidth + 14
                            Layout.preferredHeight: 22
                            radius: 11
                            color: tabRoot.isActive
                                   ? UiStyle.headerColor
                                   : UiStyle.innerCardColor
                            visible: tabs.counts[tabRoot.tabIndex] > 0

                            Behavior on color { ColorAnimation { duration: 200 } }

                            Text {
                                id: countText
                                anchors.centerIn: parent
                                text: tabs.counts[tabRoot.tabIndex]
                                font.pixelSize: 11
                                font.bold: true
                                color: tabRoot.isActive
                                       ? UiStyle.baseColor
                                       : UiStyle.subtextColor

                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (tabs.selectedIndex !== tabRoot.tabIndex) {
                                tabs.selectedIndex = tabRoot.tabIndex
                                tabs.filterChanged(tabRoot.tabIndex)
                            }
                        }
                    }
                }
            }
        }
    }
}
