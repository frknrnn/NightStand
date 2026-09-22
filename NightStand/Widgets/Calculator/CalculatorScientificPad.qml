import QtQuick
import QtQuick.Layouts

// Bilimsel tuşlar: 4 sütun x 4 satır. Ana tuş takımıyla aynı
// `keyPressed(action, value)` sözleşmesini kullanır.
GridLayout {
    id: pad

    // Açı birimi rozeti bu tuşun etiketini sürer
    property bool radians: false

    signal keyPressed(string action, var value)

    columns: 4
    rowSpacing: 10
    columnSpacing: 10

    readonly property var keys: [
        { label: "sin",  kind: "function", action: "unary", value: "sin" },
        { label: "cos",  kind: "function", action: "unary", value: "cos" },
        { label: "tan",  kind: "function", action: "unary", value: "tan" },
        { label: "DEG",  kind: "operator", action: "angle", value: null },

        { label: "ln",   kind: "function", action: "unary", value: "ln" },
        { label: "log",  kind: "function", action: "unary", value: "log" },
        { label: "eˣ",   kind: "function", action: "unary", value: "exp" },
        { label: "10ˣ",  kind: "function", action: "unary", value: "tenx" },

        { label: "√",    kind: "function", action: "unary", value: "sqrt" },
        { label: "x²",   kind: "function", action: "unary", value: "sqr" },
        { label: "xʸ",   kind: "operator", action: "op",    value: "^" },
        { label: "1/x",  kind: "function", action: "unary", value: "inv" },

        { label: "π",    kind: "function", action: "const", value: "pi" },
        { label: "e",    kind: "function", action: "const", value: "e" },
        { label: "n!",   kind: "function", action: "unary", value: "fact" },
        { label: "|x|",  kind: "function", action: "unary", value: "abs" }
    ]

    Repeater {
        model: pad.keys

        delegate: CalcButton {
            required property var modelData

            Layout.fillWidth: true
            Layout.fillHeight: true

            // Açı tuşu tek durum taşıyan tuş; etiketi diziyi yeniden kurmadan
            // burada türetiliyor, yoksa her geçişte delegate'ler baştan yaratılırdı.
            label: modelData.action === "angle"
                   ? (pad.radians ? "RAD" : "DEG")
                   : modelData.label

            kind: modelData.kind
            fontSize: 20

            onClicked: pad.keyPressed(modelData.action, modelData.value)
        }
    }
}
