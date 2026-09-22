import QtQuick
import QtQuick.Layouts

// Ana tuş takımı: 4 sütun x 5 satır.
//
// Tuşlar tek bir tabloda duruyor ve hepsi aynı `keyPressed(action, value)`
// sinyalinden akıyor; sayfa tek bir switch ile view model'e yönlendiriyor.
// Yeni tuş eklemek bu diziye bir satır yazmaktan ibaret.
GridLayout {
    id: keypad

    signal keyPressed(string action, var value)

    columns: 4
    rowSpacing: 10
    columnSpacing: 10

    readonly property var keys: [
        { label: "AC", kind: "danger",   action: "clearAll",   value: null },
        { label: "C",  kind: "function", action: "clearEntry", value: null },
        { label: "%",  kind: "function", action: "percent",    value: null },
        { label: "÷",  kind: "operator", action: "op",         value: "/" },

        { label: "7",  kind: "digit",    action: "digit",      value: 7 },
        { label: "8",  kind: "digit",    action: "digit",      value: 8 },
        { label: "9",  kind: "digit",    action: "digit",      value: 9 },
        { label: "×",  kind: "operator", action: "op",         value: "*" },

        { label: "4",  kind: "digit",    action: "digit",      value: 4 },
        { label: "5",  kind: "digit",    action: "digit",      value: 5 },
        { label: "6",  kind: "digit",    action: "digit",      value: 6 },
        { label: "−",  kind: "operator", action: "op",         value: "-" },

        { label: "1",  kind: "digit",    action: "digit",      value: 1 },
        { label: "2",  kind: "digit",    action: "digit",      value: 2 },
        { label: "3",  kind: "digit",    action: "digit",      value: 3 },
        { label: "+",  kind: "operator", action: "op",         value: "+" },

        { label: "±",  kind: "function", action: "sign",       value: null },
        { label: "0",  kind: "digit",    action: "digit",      value: 0 },
        { label: ".",  kind: "digit",    action: "dot",        value: null },
        { label: "=",  kind: "accent",   action: "equals",     value: null }
    ]

    Repeater {
        model: keypad.keys

        delegate: CalcButton {
            required property var modelData

            Layout.fillWidth: true
            Layout.fillHeight: true

            label: modelData.label
            kind: modelData.kind
            fontSize: modelData.kind === "digit" ? 30 : 28

            onClicked: keypad.keyPressed(modelData.action, modelData.value)
        }
    }
}
