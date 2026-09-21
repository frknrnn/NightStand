pragma ComponentBehavior: Bound

import QtQuick
import "../../Style"

// Dört kademeli Wi-Fi sinyal göstergesi. Durumsuz: `bars` (0-4) dışarıdan gelir.
// Kova matematiği QML'de değil, WifiNetworkModel::barsFromSignal() içinde.
Item {
    id: root

    property int bars: 0
    property color activeColor: UiStyle.textColor
    property color inactiveColor: UiStyle.subtextColor

    implicitWidth: 22
    implicitHeight: 18

    Row {
        id: barRow
        anchors.fill: parent
        spacing: 2

        Repeater {
            model: 4

            delegate: Rectangle {
                required property int index

                // Row yalnızca x'i yönetir, bu yüzden y'yi kendimiz veriyoruz:
                // çubuklar alt kenardan hizalansın.
                width: (barRow.width - barRow.spacing * 3) / 4
                height: root.height * (0.3 + index * 0.2333)
                y: root.height - height
                radius: width / 2

                color: index < root.bars ? root.activeColor : root.inactiveColor
                opacity: index < root.bars ? 1.0 : 0.3

                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }
}
