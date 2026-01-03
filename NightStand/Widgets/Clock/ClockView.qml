import QtQuick
import QtQuick.Layouts
import "../../Widgets/Clock"

Item {
    id: clockView

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        DigitalClock {
            Layout.alignment: Qt.AlignHCenter
        }

        DateDisplay {
            Layout.alignment: Qt.AlignHCenter
        }

        AnalogClock {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 40
        }
    }
}
