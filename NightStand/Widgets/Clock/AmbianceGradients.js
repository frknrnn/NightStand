.pragma library

// Ambiyans modunun gradyan kataloğu.
//
// Her gradyan üstte koyu, altta sıcak/parlak: gece lambası gibi görünsün diye.
// `to` rengi aynı zamanda sahnedeki "nefes" parıltısının rengi olarak kullanılıyor.
var list = [
    { id: "dusk",     name: "Dusk",     from: "#1B2440", to: "#E0736B" },
    { id: "ember",    name: "Ember",    from: "#2A1408", to: "#FF7A3D" },
    { id: "candle",   name: "Candle",   from: "#2E1B0A", to: "#F2B872" },
    { id: "rose",     name: "Rose",     from: "#2E1622", to: "#E2909C" },
    { id: "lavender", name: "Lavender", from: "#241640", to: "#9E86D6" },
    { id: "ocean",    name: "Ocean",    from: "#06222F", to: "#2E86AB" },
    { id: "aurora",   name: "Aurora",   from: "#07202A", to: "#2FB8A0" },
    { id: "forest",   name: "Forest",   from: "#0A2116", to: "#4FA97A" }
]

// Kalıcı ayara index değil `id` yazılıyor: liste ileride yeniden sıralanırsa
// kullanıcının seçimi kaymasın. Bilinmeyen id ilk gradyana düşer.
function indexOf(id) {
    for (var i = 0; i < list.length; ++i)
        if (list[i].id === id)
            return i
    return 0
}
