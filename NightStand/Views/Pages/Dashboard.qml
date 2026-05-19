import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../Widgets/Buttons"
import "../../Widgets/Cards"
import "../../Widgets/Clock"
import "../../Widgets/Todo"
import "../../Style"

Rectangle {
    id: dashboard
    anchors.fill: parent
    anchors.leftMargin:5
    anchors.rightMargin:5
    anchors.topMargin: 5
    anchors.bottomMargin: 5
    color: UiStyle.baseColor

    property string countdownTarget: ""

    Rectangle {
            anchors.fill: parent
            anchors.margins: 5
            color: UiStyle.cardPanelColor
            radius: 20

            ColumnLayout {
                id:dashColumnLayout
                anchors.fill: parent
                anchors.margins: 15
                spacing: 5

                RowLayout {
                    id:firstRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: 55
                    spacing: 20

                    // Night Mode Button
                    RoundButton {
                        id: nightModeButton
                        implicitWidth: 50
                        implicitHeight: 50
                        icon.source: UiStyle.iconPath("darkmode")
                        icon.width: 28
                        icon.height: 28
                        icon.color: UiStyle.textColor
                        background: Rectangle {
                            color: UiStyle.roundButtonColor
                            radius: 25
                        }
                        onClicked: {
                            appController.toggleNightMode()
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // User Button
                    RoundButton {
                        implicitWidth: 50
                        implicitHeight: 50
                        icon.source: "qrc:/icons/user.svg"
                        background: Rectangle {
                            color: UiStyle.roundButtonColor
                            radius: 25
                        }
                    }

                    // Flash Button
                    RoundButton {
                        id: flashButton
                        implicitWidth: 50
                        implicitHeight: 50
                        icon.source: UiStyle.iconPath("sun")
                        icon.width: 28
                        icon.height: 28
                        icon.color: UiStyle.textColor
                        background: Rectangle {
                            color: UiStyle.roundButtonColor
                            radius: 25
                        }
                        onClicked: {
                            appController.toggleFlashMode()
                        }
                    }
                }

                // Main Content Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: (dashColumnLayout.height - firstRow.height) / 2

                    columns: 4
                    rows: 2
                    columnSpacing: 5
                    rowSpacing: 5

                    // Clock
                    DashboardCard {
                        Layout.row: 0
                        Layout.column: 0
                        Layout.rowSpan: 2
                        Layout.columnSpan: 2
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15

                            // Time
                            Text {
                                id: timeText
                                text: dateTimeViewModel.currentTime
                                font.pixelSize: 72
                                font.bold: true
                                color: UiStyle.textColor

                                Behavior on text {
                                    SequentialAnimation {
                                        NumberAnimation {
                                            target: timeText
                                            property: "scale"
                                            to: 1.05
                                            duration: 100
                                        }
                                        NumberAnimation {
                                            target: timeText
                                            property: "scale"
                                            to: 1.0
                                            duration: 100
                                        }
                                    }
                                }
                            }

                            Text {
                                text: dateTimeViewModel.currentDate
                                font.pixelSize: 24
                                color: UiStyle.subtextColor
                            }

                            Text {
                                text: dateTimeViewModel.dayOfWeek
                                font.pixelSize: 24
                                color: UiStyle.subtextColor
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }

                    // Action buttons (2x2 grid on the right of the clock)
                    ActionCard {
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Sleep"
                        icon: "🌙"
                        onClicked: appController.toggleNightMode()
                    }

                    ActionCard {
                        Layout.row: 0
                        Layout.column: 3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Good Morning"
                        icon: "☀️"
                        onClicked: { /* TODO: morning routine */ }
                    }

                    ActionCard {
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Book"
                        icon: "📖"
                        onClicked: {
                            dashboard.countdownTarget = "reading"
                            countdownOverlay.running = true
                        }
                    }

                    ActionCard {
                        Layout.row: 1
                        Layout.column: 3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Gallery"
                        icon: "🖼️"
                        onClicked: {
                            dashboard.countdownTarget = "gallery"
                            countdownOverlay.running = true
                        }
                    }
                }

                // Bottom Section: Todo Preview + Ambiance
                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: (dashColumnLayout.height - firstRow.height) / 2
                    columns: 3
                    columnSpacing: 5

                    // Todo Preview Card (spans 2 columns)
                    DashboardCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.columnSpan: 2

                        TodoPreviewCard {
                            anchors.fill: parent
                        }
                    }

                    // Ambiance button (single column, full height)
                    ActionCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "Ambiance"
                        icon: "🎵"
                        onClicked: { /* TODO: ambiance scene */ }
                    }
                }
            }
        }

    // 3-2-1 countdown overlay (covers Dashboard; routes to reading/gallery mode on finish)
    CountdownOverlay {
        id: countdownOverlay
        onFinished: {
            if (dashboard.countdownTarget === "reading") {
                appController.readingMode = true
            } else if (dashboard.countdownTarget === "gallery") {
                appController.galleryMode = true
            }
            dashboard.countdownTarget = ""
        }
    }
}
