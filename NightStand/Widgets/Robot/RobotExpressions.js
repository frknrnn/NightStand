.pragma library

// Robot ifadelerinin tek doğruluk kaynağı.
// RobotFace görsel parametreleri, ExpressionBar ise sırayı buradan okur.
// Kullanıcıya görünen metinler burada DEĞİL: Strings/RobotStrings.qml içinde.
// Gerekçe: .pragma library motor başına bir kez değerlendirilir, buraya yazılan
// bir dizge ilk import anındaki dile donar ve dil değişiminde tazelenmez.
//
// eyeL / eyeR : göz kapağı açıklığı (0 .. 1.35)
// eyeW        : göz genişlik çarpanı
// pupil       : göz bebeği ölçeği
// pupilX/Y    : sabit bakış kayması (u birimi)
// brow        : kaş açısı (derece, + = iç uç aşağı = kızgın)
// browY       : kaş dikey kayması (u birimi, - = yukarı)
// curve       : ağız eğrisi (-1 somurtma .. +1 gülümseme)
// open        : ağız açıklığı (0 .. 1)
// blush       : yanak kızarması (0 .. 1)
// extra       : "" | "glasses" | "heart" | "sleep" | "tear" | "anger"

var order = ["mutlu", "uzgun", "saskin", "uykulu", "asik", "kizgin", "goz_kirpma", "havali"]

var data = {
    "mutlu": {
        eyeL: 1.00, eyeR: 1.00, eyeW: 1.00, pupil: 1.00, pupilX: 0.0, pupilY: 0.0,
        brow: -4, browY: -1.0, curve: 1.00, open: 0.45, blush: 0.35, extra: ""
    },
    "uzgun": {
        eyeL: 0.80, eyeR: 0.80, eyeW: 1.00, pupil: 1.10, pupilX: 0.0, pupilY: 1.4,
        brow: -15, browY: 1.5, curve: -0.90, open: 0.00, blush: 0.10, extra: "tear"
    },
    "saskin": {
        eyeL: 1.32, eyeR: 1.32, eyeW: 1.12, pupil: 0.58, pupilX: 0.0, pupilY: 0.0,
        brow: -8, browY: -4.5, curve: 0.05, open: 1.00, blush: 0.15, extra: ""
    },
    "uykulu": {
        eyeL: 0.26, eyeR: 0.26, eyeW: 1.00, pupil: 0.95, pupilX: 0.0, pupilY: 1.6,
        brow: 6, browY: 2.0, curve: -0.15, open: 0.28, blush: 0.20, extra: "sleep"
    },
    "asik": {
        eyeL: 1.05, eyeR: 1.05, eyeW: 1.00, pupil: 1.00, pupilX: 0.0, pupilY: 0.0,
        brow: -9, browY: -2.0, curve: 0.90, open: 0.32, blush: 0.70, extra: "heart"
    },
    "kizgin": {
        eyeL: 0.62, eyeR: 0.62, eyeW: 1.08, pupil: 0.85, pupilX: 0.0, pupilY: -0.6,
        brow: 21, browY: 3.0, curve: -0.85, open: 0.16, blush: 0.25, extra: "anger"
    },
    "goz_kirpma": {
        eyeL: 1.05, eyeR: 0.06, eyeW: 1.00, pupil: 1.00, pupilX: 0.6, pupilY: 0.0,
        brow: -6, browY: -1.0, curve: 0.75, open: 0.22, blush: 0.30, extra: ""
    },
    "havali": {
        eyeL: 0.90, eyeR: 0.90, eyeW: 1.00, pupil: 0.95, pupilX: 0.0, pupilY: 0.0,
        brow: -2, browY: 0.0, curve: 0.60, open: 0.12, blush: 0.10, extra: "glasses"
    }
}

function get(id) {
    return data[id] !== undefined ? data[id] : data["mutlu"]
}
