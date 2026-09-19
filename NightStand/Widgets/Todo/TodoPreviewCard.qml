import QtQuick
import QtQuick.Layouts
import "../Common"
import "../../Style"

Rectangle {
    id: root

    signal clicked()

    // TodoViewModel'in NOTIFY sinyalli Q_PROPERTY'lerine bağlı - tek seferlik
    // Q_INVOKABLE'lara değil. Eski kartın hiç güncellenmemesinin sebebi buydu.
    readonly property int totalCount:     todoViewModel ? todoViewModel.totalCount     : 0
    readonly property int completedCount: todoViewModel ? todoViewModel.completedCount : 0
    readonly property int pendingCount:   todoViewModel ? todoViewModel.pendingCount   : 0
    readonly property real progress: totalCount > 0 ? completedCount / totalCount : 0

    // DashboardCard / ActionCard ile aynı görünüm - hiçbir şey kaymıyor.
    radius: 16
    color: UiStyle.innerCardColor
    border.width: 2
    border.color: cardArea.containsMouse ? UiStyle.headerColor : UiStyle.transparent

    scale:   cardArea.pressed ? 0.98 : 1.0
    opacity: cardArea.pressed ? 0.92 : 1.0

    Behavior on scale        { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on opacity      { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on border.color { ColorAnimation  { duration: 150 } }

    // Tek sayaç: büyük rakam + küçük büyükharf etiket.
    component StatColumn: ColumnLayout {
        property int value: 0
        property string caption: ""
        property color tone: UiStyle.textColor

        spacing: 2

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: value
            font.pixelSize: 38
            font.bold: true
            color: tone
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: caption
            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 1.0
            color: UiStyle.subtextColor
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        // ---------- başlık ----------
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            spacing: 10

            ThemedIcon {
                source: UiStyle.monoIconPath("clipboard-list")
                size: 20
                color: UiStyle.textColor
            }

            Text {
                text: qsTr("Tasks")
                font.pixelSize: 17
                font.bold: true
                color: UiStyle.textColor
            }

            Item { Layout.fillWidth: true }

            // "Bu kart bir yere gider" işareti
            ThemedIcon {
                source: UiStyle.monoIconPath("chevron-right")
                size: 18
                color: UiStyle.subtextColor
                opacity: cardArea.containsMouse ? 1.0 : 0.55
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }

        Item { Layout.fillHeight: true; Layout.minimumHeight: 0 }

        // ---------- bekleyen / toplam / tamamlanan ----------
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            StatColumn {
                Layout.fillWidth: true
                value: root.pendingCount
                caption: qsTr("PENDING")
                tone: UiStyle.textColor
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignVCenter
                color: UiStyle.subtextColor
                opacity: 0.25
            }

            StatColumn {
                Layout.fillWidth: true
                value: root.totalCount
                caption: qsTr("TOTAL")
                tone: UiStyle.subtextColor
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignVCenter
                color: UiStyle.subtextColor
                opacity: 0.25
            }

            StatColumn {
                Layout.fillWidth: true
                value: root.completedCount
                caption: qsTr("COMPLETED")
                tone: UiStyle.buttonProgress
            }
        }

        // ---------- ilerleme ----------
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            visible: root.totalCount > 0

            Rectangle {
                id: track
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 6
                radius: 3
                color: UiStyle.roundButtonColor

                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    width: parent.width * root.progress
                    color: UiStyle.buttonProgress
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.top: track.bottom
                anchors.topMargin: 6
                text: qsTr("%1 of %2 completed").arg(root.completedCount).arg(root.totalCount)
                font.pixelSize: 12
                color: UiStyle.subtextColor
            }
        }

        // ---------- boş durum ----------
        // İlerleme bloğuyla aynı 26 px'lik yuvayı kaplıyor; ilk görev
        // eklendiğinde kart zıplamasın diye.
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            visible: root.totalCount === 0
            text: qsTr("No tasks yet - tap to add one")
            font.pixelSize: 13
            color: UiStyle.subtextColor
            verticalAlignment: Text.AlignVCenter
        }
    }

    // En sonda tanımlanıyor ki layout'un üstünde kalsın ve her basmayı yakalasın.
    MouseArea {
        id: cardArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
