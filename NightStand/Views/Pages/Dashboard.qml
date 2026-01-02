import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../../Widgets/Cards"
import "../../Style"

Rectangle {
    anchors.fill: parent
    anchors.leftMargin:5
    anchors.rightMargin:5
    anchors.topMargin: 5
    anchors.bottomMargin: 5
    color: UiStyle.baseColor

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

                    // Search Button
                    RoundButton {
                        implicitWidth: 50
                        implicitHeight: 50
                        icon.source: "qrc:/icons/search.svg"
                        background: Rectangle {
                            color: UiStyle.roundButtonColor
                            radius: 25
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

                    // Settings Button
                    RoundButton {
                        implicitWidth: 50
                        implicitHeight: 50
                        icon.source: "qrc:/icons/settings.svg"
                        background: Rectangle {
                            color: UiStyle.roundButtonColor
                            radius: 25
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

                    // Clock & Weather Card (2x2)
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

                            // // Weather
                            // RowLayout {
                            //     spacing: 15

                            //     Image {
                            //         source: "qrc:/icons/cloud-rain.svg"
                            //         sourceSize: Qt.size(60, 60)
                            //     }

                            //     ColumnLayout {
                            //         spacing: 5
                            //         Text {
                            //             text: "22°C"
                            //             font.pixelSize: 28
                            //             font.bold: true
                            //             color: UiStyle.textColor
                            //         }
                            //         Text {
                            //             text: "Cloudy to Rainy"
                            //             font.pixelSize: 14
                            //             color:UiStyle.subtextColor
                            //         }
                            //     }
                            // }
                        }
                    }

                    // Scene Cards (1x1 each)
                    SceneCard {
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        sceneName: "At Home"
                        icon: "🏠"
                        isActive: true
                    }

                    SceneCard {
                        Layout.row: 0
                        Layout.column: 3
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        sceneName: "Leave Home"
                        icon: "🚗"
                    }

                    SceneCard {
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        sceneName: "Night"
                        icon: "🌙"
                    }

                    SceneCard {
                        Layout.row: 1
                        Layout.column: 3
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        sceneName: "Movie Watching"
                        icon: "🎬"
                    }
                }

                // Bottom Section
                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: (dashColumnLayout.height - firstRow.height) / 2
                    columns: 3
                    columnSpacing: 5

                    // AC Control Card
                    DashboardCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Air Conditioner"
                                    font.pixelSize: 16
                                    color: UiStyle.subtextColor
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "Working ❄️"
                                    font.pixelSize: 14
                                    color: UiStyle.subtextColor
                                }
                            }

                            Item { Layout.fillHeight: true }

                            Text {
                                text: "24°C"
                                font.pixelSize: 48
                                font.bold: true
                                color: UiStyle.textColor
                            }

                            Text {
                                text: "❄️ Cooling"
                                font.pixelSize: 14
                                color: UiStyle.subtextColor
                            }

                            Item { Layout.fillHeight: true }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Settings"
                                    font.pixelSize: 14
                                    color: UiStyle.headerColor
                                }
                                Item { Layout.fillWidth: true }
                                Switch {
                                    checked: true
                                }
                            }
                        }
                    }

                    // Security Card
                    DashboardCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 5

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "PIR Sensor"
                                    font.pixelSize: 16
                                    color: "#7a8fa8"
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    width: 60
                                    height: 24
                                    color: "#2a3f5f"
                                    radius: 12
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Low 🔋"
                                        font.pixelSize: 11
                                        color: "#7a8fa8"
                                    }
                                }
                            }

                            Text {
                                text: "Home secured"
                                font.pixelSize: 20
                                font.bold: true
                                color: "white"
                            }

                            ColumnLayout {
                                spacing: 8

                                Text {
                                    text: "Activities:"
                                    font.pixelSize: 12
                                    color: "#7a8fa8"
                                }

                                ActivityItemCard {
                                    text: "Someone has passed in Garden"
                                    time: "20 min ago"
                                }

                                ActivityItemCard {
                                    text: "Someone has passed in Garden"
                                    time: "37 min ago"
                                }
                            }

                            Item { Layout.fillHeight: true }

                            RowLayout {
                                Layout.fillWidth: true
                                Rectangle {
                                    width: 30
                                    height: 30
                                    color: "#2a3f5f"
                                    radius: 15
                                    Text {
                                        anchors.centerIn: parent
                                        text: "🛡️"
                                        font.pixelSize: 14
                                    }
                                }
                                Text {
                                    text: "Security on"
                                    font.pixelSize: 14
                                    color: "#7a8fa8"
                                }
                            }
                        }
                    }

                    // Room Controls
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 15

                        // Living Room Card
                        ControlCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            roomName: "Living room"
                            brightness: 60
                        }

                        // Bedroom Card
                        ControlCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            roomName: "Bedroom"
                            brightness: 20
                            category: "Curtains"
                        }
                    }
                }
            }
        }
}
