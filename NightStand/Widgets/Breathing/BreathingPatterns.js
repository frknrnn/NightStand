.pragma library

// Nefes egzersizi modlarının kataloğu.
//
// Süreler burada milisaniye olarak duruyor ama EKRANDA HİÇBİR YERDE saniye/rakam
// gösterilmiyor - ritim yalnızca animasyondan okunuyor.
//
// `kind` değerleri BreathingOverlay'in durum makinesi tarafından okunuyor:
//   in      -> nefes al   (breathLevel 0 -> 1)
//   holdIn  -> dolu tut   (breathLevel 1'de sabit)
//   out     -> nefes ver  (breathLevel 1 -> 0)
//   holdOut -> boş tut    (breathLevel 0'da sabit)
var IN = "in"
var HOLD_IN = "holdIn"
var OUT = "out"
var HOLD_OUT = "holdOut"

var list = [
    {
        id: "rahatlama",
        visual: "petals",
        cycles: 5,
        phases: [
            { kind: IN,      ms: 6000 },
            { kind: HOLD_IN, ms: 6000 },
            { kind: OUT,     ms: 6000 },
            { kind: HOLD_OUT, ms: 6000 }
        ]
    },
    {
        id: "odaklanma",
        visual: "box",
        cycles: 10,
        phases: [
            { kind: IN,      ms: 5000 },
            { kind: HOLD_IN, ms: 5000 },
            { kind: OUT,     ms: 5000 },
            { kind: HOLD_OUT, ms: 5000 }
        ]
    },
    {
        id: "sakin",
        visual: "dots",
        cycles: 10,
        phases: [
            { kind: IN,  ms: 4000 },
            { kind: OUT, ms: 4000 }
        ]
    }
]
