pragma Singleton

import QtQuick

// User-visible robot text. It lives here rather than in RobotExpressions.js
// because a .pragma library script is evaluated ONCE per engine: a string baked
// into a top-level `var` would freeze at the startup language and never follow a
// live switch. These are functions, so the qsTr() runs while a binding is being
// evaluated - which is exactly what QQmlEngine::retranslate() picks up.
//
// RobotExpressions.js keeps the geometry; only the text moved.
QtObject {
    // Speech-bubble line per expression id.
    function line(id) {
        switch (id) {
        //: Bugün harika hissediyorum!
        case "mutlu":       return qsTr("I feel great today!")
        //: Biraz moralim bozuk...
        case "uzgun":       return qsTr("I'm feeling a bit down...")
        //: Vay canına! Bu da neydi?
        case "saskin":      return qsTr("Whoa! What was that?")
        //: Çok uykum var... iyi geceler.
        case "uykulu":      return qsTr("I'm so sleepy... good night.")
        //: Kalbim küt küt atıyor!
        case "asik":        return qsTr("My heart is pounding!")
        //: Şimdi gerçekten sinirlendim!
        case "kizgin":      return qsTr("Now I'm really annoyed!")
        //: Aramızda kalsın, tamam mı?
        case "goz_kirpma":  return qsTr("Just between us, alright?")
        //: Bugün fena havalıyım, değil mi?
        case "havali":      return qsTr("Looking pretty sharp today, right?")
        }
        return qsTr("I feel great today!")
    }

    readonly property int pokeCount: 5

    // Replies when the face is tapped. Addressed by index, not returned at
    // random as a stored string: RobotPage keeps the index and calls this from a
    // binding, so the reply follows a language switch. Store language-neutral
    // state, translate at the point of display.
    function poke(index) {
        switch (index) {
        //: Hey, gıdıklanıyorum!
        case 0: return qsTr("Hey, that tickles!")
        //: Bip bop! Dokundun bana.
        case 1: return qsTr("Beep boop! You poked me.")
        //: Yine mi sen? Çok tatlısın.
        case 2: return qsTr("You again? You're sweet.")
        //: Vızzz! Devrelerim karıncalandı.
        case 3: return qsTr("Bzzt! My circuits are tingling.")
        //: Bir daha dokun, hoşuma gitti!
        case 4: return qsTr("Do that again, I liked it!")
        }
        return ""
    }

    function randomPokeIndex() {
        return Math.floor(Math.random() * pokeCount)
    }
}
