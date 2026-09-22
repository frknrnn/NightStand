import QtQuick
import QtQuick.Layouts
import "../Style"
import "../AppSettings"
import "../Widgets/Calculator"

Rectangle {
    id: calculatorPage
    anchors.fill: parent
    color: UiStyle.baseColor

    // Ayarın kendisi tek doğru kaynak; yerel kopya tutulmuyor, böylece
    // binding hiç kopmuyor (ClockView'daki clockMode kalıbının aynısı).
    readonly property bool scientific: UiSettings.calculatorScientific

    // Açı birimi C++ tarafında yaşıyor, o yüzden sayfa açılırken bir kez
    // ayardan view model'e taşınıyor.
    Component.onCompleted: calculatorViewModel.setRadians(UiSettings.calculatorRadians)

    // İki tuş takımı da aynı sözleşmeden akar; yönlendirme tek yerde.
    function handleKey(action, value) {
        switch (action) {
        case "digit":      calculatorViewModel.digit(value); break
        case "dot":        calculatorViewModel.decimalPoint(); break
        case "op":         calculatorViewModel.op(value); break
        case "unary":      calculatorViewModel.unary(value); break
        case "const":      calculatorViewModel.constant(value); break
        case "equals":     calculatorViewModel.equals(); break
        case "percent":    calculatorViewModel.percent(); break
        case "sign":       calculatorViewModel.toggleSign(); break
        case "clearEntry": calculatorViewModel.clearEntry(); break
        case "clearAll":   calculatorViewModel.clearAll(); break
        case "angle":
            calculatorViewModel.setRadians(!calculatorViewModel.radians)
            UiSettings.calculatorRadians = calculatorViewModel.radians
            break
        default:
            console.warn("CalculatorPage: bilinmeyen tuş", action)
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 60      // PageTopBarItem'in altında kal
        anchors.bottomMargin: 16
        spacing: 16

        CalculatorHistoryPanel {
            Layout.preferredWidth: 240
            Layout.fillHeight: true

            entries: calculatorViewModel.historyModel
            entryCount: calculatorViewModel.historyCount

            onEntryClicked: (index) => calculatorViewModel.recall(index)
            onClearRequested: calculatorViewModel.clearHistory()
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            CalculatorDisplay {
                Layout.fillWidth: true
                Layout.preferredHeight: 112

                expression: calculatorViewModel.expressionText
                value: calculatorViewModel.displayText
                error: calculatorViewModel.hasError
                scientific: calculatorPage.scientific
                radians: calculatorViewModel.radians

                onToggleScientific: UiSettings.calculatorScientific = !UiSettings.calculatorScientific
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // Panel sabit 300 px genişlikte durur, yuva daralarak onu kırpar.
                // Layout.preferredWidth'e doğrudan Behavior konulamadığı için
                // animasyon yerel bir özellik üzerinden sürülüyor.
                Item {
                    id: scientificSlot

                    property real slotWidth: calculatorPage.scientific ? 300 : 0

                    Behavior on slotWidth {
                        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                    }

                    Layout.preferredWidth: slotWidth
                    Layout.fillHeight: true
                    // Bilerek gizlenmiyor: RowLayout görünmez öğeyi boşluğuyla
                    // birlikte atıyor, o yüzden açılış anında 12 px'lik bir
                    // sıçrama olurdu. Genişlik 0 + clip zaten hiçbir şey çizmiyor.
                    clip: true

                    CalculatorScientificPad {
                        width: 300
                        height: parent.height

                        radians: calculatorViewModel.radians

                        onKeyPressed: (action, value) => calculatorPage.handleKey(action, value)
                    }
                }

                CalculatorKeypad {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onKeyPressed: (action, value) => calculatorPage.handleKey(action, value)
                }
            }
        }
    }
}
