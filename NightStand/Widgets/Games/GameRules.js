.pragma library

// Oyunların tüm ayar sabitleri ve saf yardımcıları. Kullanıcıya görünen metin
// burada YOK (Strings/GameStrings.qml'de) - .pragma library motor başına bir kez
// değerlendiği için buraya yazılan bir dizge dil değişiminde tazelenmezdi.
//
// Birimler: mesafe px, süre saniye. Hızlar px/s, ivmeler px/s^2. Sahne 1024x600
// varsayılarak ayarlandı ama her şey oran/piksel karışımı değil, saf piksel:
// pencere büyürse oyun alanı da büyür, zorluk aynı kalır.

var flappy = {
    gravity: 1750,          // px/s^2
    impulse: 520,           // dokunuşta yukarı verilen hız
    maxFall: 900,           // düşüş hız tavanı - tünelleme olmasın
    startSpeed: 250,        // kapıların sola akış hızı
    speedPerScore: 6,       // her kapıda hızlanma
    maxSpeed: 430,
    startGap: 200,          // dikey boşluk
    gapPerScore: 3.2,       // her kapıda daralma
    minGap: 140,
    gateWidth: 66,
    gateSpacing: 330,       // iki kapı arası yatay mesafe
    gateCount: 3,           // geri dönüştürülen havuz boyutu
    playerX: 0.26,          // ekran genişliğinin oranı
    hitbox: 0.62,           // robot kutusunun affedicilik çarpanı
    tiltUp: -22,
    tiltDown: 70
}

var runner = {
    gravity: 2900,
    impulse: 950,
    startSpeed: 380,
    speedPerSec: 9,         // saniyede hızlanma
    maxSpeed: 760,
    groundY: 0.80,          // ekran yüksekliğinin oranı
    playerX: 0.18,
    obstacleCount: 3,
    minGapPx: 300,          // engeller arası en az mesafe
    gapJitter: 260,
    minHeight: 42,
    maxHeight: 92,
    minWidth: 26,
    maxWidth: 46,
    scoreDivisor: 26,       // mesafe -> puan
    hitbox: 0.58
}

var reflex = {
    rounds: 5,
    minWait: 1200,          // ms
    maxWait: 3400,
    tooEarlyMs: 900         // erken dokunuşta gösterilen uyarı süresi
}

// Kare başına delta tavanı. Pencere donar/arka plana düşerse frameTime birden
// büyür ve oyuncu engelin içinden geçer; bunu kesiyoruz.
var maxStep = 0.05

function clamp(v, lo, hi) {
    return v < lo ? lo : (v > hi ? hi : v)
}

// Eksen hizalı dikdörtgen çakışması
function overlaps(ax, ay, aw, ah, bx, by, bw, bh) {
    return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

function randomBetween(lo, hi) {
    return lo + Math.random() * (hi - lo)
}

function flappySpeed(score) {
    return Math.min(flappy.maxSpeed, flappy.startSpeed + score * flappy.speedPerScore)
}

function flappyGap(score) {
    return Math.max(flappy.minGap, flappy.startGap - score * flappy.gapPerScore)
}

function runnerSpeed(elapsed) {
    return Math.min(runner.maxSpeed, runner.startSpeed + elapsed * runner.speedPerSec)
}
