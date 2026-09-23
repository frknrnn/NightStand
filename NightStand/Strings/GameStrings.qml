pragma Singleton

import QtQuick

// User-visible game text. It lives here rather than in GameRules.js because a
// .pragma library script is evaluated ONCE per engine: a string baked into a
// top-level `var` would freeze at the startup language and never follow a live
// switch. These are functions, so the qsTr() runs while a binding is being
// evaluated - which is what QQmlEngine::retranslate() picks up.
//
// GameRules.js keeps the physics constants; only the text lives here.
QtObject {
    // Game name, by id.
    function title(id) {
        switch (id) {
        //: Robot Uçuşu
        case "flappy": return qsTr("Robot Flight")
        //: Robot Koşusu
        case "runner": return qsTr("Robot Run")
        //: Robot Refleks
        case "reflex": return qsTr("Robot Reflex")
        }
        return ""
    }

    // One-line description shown on the menu card.
    function tagline(id) {
        switch (id) {
        //: Kapılardan süzülerek geç
        case "flappy": return qsTr("Glide through the gates")
        //: Engellerin üstünden atla
        case "runner": return qsTr("Jump over the obstacles")
        //: Hedef belirince hemen dokun
        case "reflex": return qsTr("Tap the moment the target lights up")
        }
        return ""
    }

    // In-game hint, shown until the first tap.
    function hint(id) {
        switch (id) {
        //: Süzülmek için dokun
        case "flappy": return qsTr("Tap to fly")
        //: Zıplamak için dokun
        case "runner": return qsTr("Tap to jump")
        //: Hedefi bekle
        case "reflex": return qsTr("Wait for the target")
        }
        return ""
    }

    // Score unit on the game-over card. Reflex measures milliseconds, the
    // others count points, and lower is better only for reflex.
    function scoreLabel(id) {
        switch (id) {
        //: Ortalama
        case "reflex": return qsTr("Average")
        }
        //: Skor
        return qsTr("Score")
    }
}
