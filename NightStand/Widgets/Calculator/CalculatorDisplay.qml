import QtQuick
import QtQuick.Layouts
import "../../Style"

// İki satırlı ekran: üstte yürüyen ifade ve mod rozetleri, altta sonuç.
Rectangle {
    id: display

    property string expression: ""
    property string value: "0"
    property bool error: false
    property bool scientific: false
    property bool radians: false

    signal toggleScientific()

    radius: 20
    color: UiStyle.cardPanelColor

    Behavior on color { ColorAnimation { duration: 250 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 12
        anchors.bottomMargin: 14
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Bilimsel paneli açıp kapatan rozet
            Rectangle {
                Layout.preferredWidth: 46
                Layout.preferredHeight: 28
                radius: 14
                color: display.scientific ? UiStyle.headerColor : UiStyle.roundButtonColor
                scale: fxArea.pressed ? 0.93 : 1.0

                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }

                Text {
                    anchors.centerIn: parent
                    text: "fx"
                    font.pixelSize: 14
                    font.bold: true
                    // Dolu rozette onHeaderColor şart: black temasında
                    // headerColor beyaz, sabit beyaz yazı kaybolurdu.
                    color: display.scientific ? UiStyle.onHeaderColor
                                              : UiStyle.subtextColor

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    id: fxArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: display.toggleScientific()
                }
            }

            // Radyan modu sonuçları değiştirdiği için panel kapalıyken de görünür
            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 28
                radius: 14
                color: UiStyle.transparent
                border.width: 1
                border.color: UiStyle.headerColor
                visible: display.radians

                Text {
                    anchors.centerIn: parent
                    text: "RAD"
                    font.pixelSize: 11
                    font.bold: true
                    color: UiStyle.headerColor
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: display.expression
                font.pixelSize: 18
                color: UiStyle.subtextColor
                elide: Text.ElideLeft
                opacity: text.length > 0 ? 1.0 : 0.0

                Behavior on opacity { NumberAnimation { duration: 180 } }
            }
        }

        // Sonuç. HorizontalFit uzun sayılarda punto düşürür; taşma olmaz.
        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter

            text: display.value
            font.pixelSize: 54
            font.bold: true
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 22

            color: display.error ? UiStyle.red : UiStyle.textColor

            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
}
