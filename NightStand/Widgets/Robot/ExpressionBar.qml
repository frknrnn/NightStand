pragma ComponentBehavior: Bound

import QtQuick
import "RobotExpressions.js" as RobotExpr

// 8 ifade butonu, ortalanmış tek sıra. Buton boyutu genişliğe göre kısılır
// ama asla 48px dokunma tabanının altına inmez.
Item {
    id: bar

    property string current: "mutlu"
    property int gap: 12

    readonly property int buttonSize: Math.max(48, Math.min(84, Math.floor((width - 7 * gap) / 8)))

    signal expressionSelected(string id)

    implicitHeight: buttonSize + 6

    Row {
        anchors.centerIn: parent
        spacing: bar.gap

        Repeater {
            model: RobotExpr.order

            delegate: ExpressionButton {
                required property string modelData

                expressionId: modelData
                buttonSize: bar.buttonSize
                selected: bar.current === modelData

                onClicked: bar.expressionSelected(modelData)
            }
        }
    }
}
