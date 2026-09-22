import QtQuick
import QtQuick.Layouts
import "../../Style"

// Ağ listesi satırı. CharacterSelector sözleşmesi: durumsuz — seçili olup
// olmadığı dışarıdan gelir, tıklama yalnızca sinyal yayar.
Item {
    id: root

    property string ssid: ""
    property int signalStrength: 0
    property int bars: 0
    property string security: ""
    property bool secured: false
    property bool enterprise: false
    property bool active: false
    property bool saved: false

    property bool selected: false
    property bool pending: false

    signal clicked()

    implicitHeight: 62
    scale: pressArea.pressed ? 0.98 : 1.0

    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.selected ? UiStyle.innerCardColor : UiStyle.transparent
        border.width: root.selected ? 2 : 1
        border.color: root.selected ? UiStyle.headerColor : UiStyle.roundButtonColor

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        SignalBars {
            Layout.alignment: Qt.AlignVCenter
            bars: root.bars
            activeColor: root.active ? UiStyle.buttonProgress : UiStyle.textColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.ssid
                font.pixelSize: 16
                font.bold: root.selected || root.active
                color: root.selected ? UiStyle.headerColor : UiStyle.textColor
                elide: Text.ElideRight

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (root.enterprise)
                        return qsTr("Enterprise (802.1X) — not supported")
                    var label = root.secured ? root.security : qsTr("Open network")
                    //: %1 güvenlik tipi ("WPA2") veya "Açık ağ", %2 sinyal yüzdesi
                    return qsTr("%1 · %2%").arg(label).arg(root.signalStrength)
                }
                font.pixelSize: 11
                color: UiStyle.subtextColor
                elide: Text.ElideRight
            }
        }

        // Durum rozeti: bağlı / bağlanıyor / kayıtlı
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            visible: root.active || root.saved || root.pending
            implicitWidth: badgeText.implicitWidth + 18
            implicitHeight: 24
            radius: 12
            color: root.active ? UiStyle.buttonProgress : UiStyle.transparent
            border.width: root.active ? 0 : 1
            border.color: UiStyle.roundButtonColor

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: root.pending ? "…"
                    : root.active ? qsTr("Connected")
                    : qsTr("Saved")
                font.pixelSize: 11
                font.bold: true
                color: root.active ? UiStyle.contrastOn(UiStyle.buttonProgress)
                                   : UiStyle.subtextColor
            }
        }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
