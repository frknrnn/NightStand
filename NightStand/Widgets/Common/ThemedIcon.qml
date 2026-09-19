// ThemedIcon.qml
//
// Tek kare, düz boyanmış ikon. SVG'nin kendi renkleri önemsiz: IconImage,
// `color`'ı rasterize edilmiş glifin üzerine SourceIn ile bindiriyor, yalnızca
// glifin alfası hayatta kalıyor. Uygulamadaki her ikonun koyu temalarda saf
// beyaz, açık temada saf siyah olmasını sağlayan mekanizma bu.
import QtQuick
import QtQuick.Controls.impl as ControlsImpl
import "../../Style"

ControlsImpl.IconImage {
    id: root

    // Kare glifin kenar uzunluğu (mantıksal piksel).
    property int size: 24

    // `source` (url) ve `color` (color) IconImage'dan miras alınıyor.
    // `color` C++ tarafında FINAL - burada asla yeniden tanımlanmaz,
    // yalnızca bağlanır.
    color: UiStyle.textColor

    width: root.size
    height: root.size

    // SVG'yi tam çizim boyutunda rasterize et ki her `size` değerinde net kalsın.
    // fillMode'a dokunma - IconImage onu kendisi yönetiyor, üzerine yazılır.
    sourceSize.width: root.size
    sourceSize.height: root.size

    smooth: true

    // Boş source -> status Null, hiçbir şey çizilmez. Gizlemek ayrıca
    // RowLayout/ColumnLayout'un boş bir yer ayırmasını da engeller.
    visible: root.source.toString() !== ""
}
