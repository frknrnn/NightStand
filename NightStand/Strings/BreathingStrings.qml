pragma Singleton

import QtQuick

// User-visible text for the breathing overlay. It lives here rather than in
// BreathingPatterns.js because a .pragma library script is evaluated ONCE per
// engine: a string baked into a top-level `var` would freeze at the startup
// language and never follow a live switch. These are functions, so the qsTr()
// runs while a binding is being evaluated - which is what retranslate() catches.
//
// BreathingPatterns.js keeps the timings and ids; only the text moved.
QtObject {
    // Phase label. The kind values come from BreathingPatterns.js.
    function phaseLabel(kind) {
        switch (kind) {
        //: Nefes Al
        case "in":      return qsTr("Breathe in")
        //: Tut
        case "holdIn":  return qsTr("Hold")
        //: Nefes Ver
        case "out":     return qsTr("Breathe out")
        //: Tut
        case "holdOut": return qsTr("Hold")
        }
        return ""
    }

    // Mode name, by pattern id. "Hold" above deliberately appears twice: same
    // context, same source text, one .ts entry, one translation.
    function patternLabel(id) {
        switch (id) {
        //: Rahatlama
        case "rahatlama": return qsTr("Relax")
        //: Odaklanma
        case "odaklanma": return qsTr("Focus")
        //: Sakin
        case "sakin":     return qsTr("Calm")
        }
        return ""
    }
}
