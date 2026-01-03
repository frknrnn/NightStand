import QtQuick
import "../../Style"

Text {
    id: dateText
    font.pixelSize: 18
    color: UiStyle.subtextColor
    text: Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")
}
