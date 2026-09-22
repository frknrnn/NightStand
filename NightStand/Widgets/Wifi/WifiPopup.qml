import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../AppSettings"
import "../../Style"
import "../Buttons"

// Wi-Fi bağlantı penceresi. AddAlarmPopup sözleşmesi: modal Popup, el yapımı
// Rectangle + MouseArea butonlar, kullanım yerinde `parent: Overlay.overlay`.
//
// İki panelli düzen bilerek seçildi: şifre alanı ListView delegate'inin içinde
// olsaydı, satır geri dönüştürüldüğünde odağını ve yazılan metni kaybederdi.
Popup {
    id: wifiPopup

    // Seçim popup'ın kendi durumu — satırlar durumsuz, yalnızca sinyal yayar.
    // Statik alanlar (güvenlik tipi) seçim anında satırdan alınır; değişken
    // olanlar (saved/active) doğrudan wifiManager'dan okunur ki bayatlamasın.
    property string selectedSsid: ""
    property bool selSecured: false
    property bool selEnterprise: false
    property string selSecurity: ""
    property int selSignal: -1

    // Kayıtlı bir ağın saklı şifresi geçersizse alanı zorla açmak için.
    property bool passwordRequested: false
    property bool showPassword: false

    property string inlineError: ""
    property string inlineInfo: ""

    readonly property bool hasSelection: wifiPopup.selectedSsid !== ""
    readonly property bool selSaved: wifiPopup.hasSelection
                                     && wifiManager.savedSsids.indexOf(wifiPopup.selectedSsid) >= 0
    readonly property bool selActive: wifiPopup.hasSelection && wifiManager.connected
                                      && wifiManager.currentSsid === wifiPopup.selectedSsid
    readonly property bool needsPassword: wifiPopup.selSecured && !wifiPopup.selEnterprise
                                          && (!wifiPopup.selSaved || wifiPopup.passwordRequested)
    readonly property bool bodyUsable: wifiManager.supported && wifiManager.radioOn

    readonly property bool keyboardVisible: Qt.inputMethod.visible

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    width: Math.min(parent.width * 0.86, 880)

    // Klavye açıkken pencereyi kaydırmak yerine KÜÇÜLTÜYORUZ.
    // Qt.inputMethod.keyboardRectangle'ın birimi (fiziksel/mantıksal piksel)
    // platforma göre değişiyor; yükseklik oranı ise her yerde aynı davranıyor.
    readonly property real fullHeight: Math.min(parent.height * 0.92, 540)
    height: wifiPopup.keyboardVisible ? Math.min(parent.height * 0.55, wifiPopup.fullHeight)
                                      : wifiPopup.fullHeight

    x: (parent.width - width) / 2
    y: wifiPopup.keyboardVisible ? 10 : (parent.height - height) / 2

    Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    background: Rectangle {
        color: UiStyle.cardPanelColor
        radius: 22
        border.width: 1
        border.color: UiStyle.roundButtonColor
    }

    // Popup açıkken daha sık yoklanır (3 sn), kapalıyken 10 sn'ye düşer ve
    // pahalı ağ listesi sorgusu tamamen devre dışı kalır.
    onVisibleChanged: wifiManager.setPopupOpen(wifiPopup.visible)

    onOpened: {
        wifiPopup.resetSelection()
        wifiManager.clearError()
        wifiManager.scan()
    }

    onClosed: Qt.inputMethod.hide()

    function resetSelection() {
        wifiPopup.selectedSsid = ""
        wifiPopup.selSecured = false
        wifiPopup.selEnterprise = false
        wifiPopup.selSecurity = ""
        wifiPopup.selSignal = -1
        wifiPopup.passwordRequested = false
        wifiPopup.showPassword = false
        wifiPopup.inlineError = ""
        wifiPopup.inlineInfo = ""
        passwordField.text = ""
    }

    function selectNetwork(ssid, secured, enterprise, security, strength) {
        if (wifiPopup.selectedSsid !== ssid) {
            passwordField.text = ""
            wifiPopup.passwordRequested = false
            wifiPopup.showPassword = false
            wifiPopup.inlineError = ""
            wifiPopup.inlineInfo = ""
            wifiManager.clearError()
        }
        wifiPopup.selectedSsid = ssid
        wifiPopup.selSecured = secured
        wifiPopup.selEnterprise = enterprise
        wifiPopup.selSecurity = security
        wifiPopup.selSignal = strength
    }

    function doConnect() {
        if (!wifiPopup.hasSelection || wifiManager.busy)
            return
        wifiPopup.inlineError = ""
        wifiPopup.inlineInfo = ""

        if (wifiPopup.selEnterprise) {
            wifiPopup.inlineError = qsTr("Enterprise (802.1X) networks are not supported.")
            return
        }
        if (wifiPopup.needsPassword) {
            if (passwordField.text.length === 0) {
                wifiPopup.inlineError = qsTr("Enter a password.")
                return
            }
            wifiManager.connectToNetwork(wifiPopup.selectedSsid, passwordField.text)
        } else {
            // Kayıtlı profil ya da açık ağ: ikisini de connectToSaved hallediyor.
            wifiManager.connectToSaved(wifiPopup.selectedSsid)
        }
    }

    function doForget() {
        if (!wifiPopup.hasSelection || wifiManager.busy)
            return
        wifiPopup.inlineError = ""
        wifiPopup.inlineInfo = ""
        wifiPopup.passwordRequested = false
        passwordField.text = ""
        wifiManager.forgetNetwork(wifiPopup.selectedSsid)
    }

    Connections {
        target: wifiManager

        function onConnectSucceeded(ssid) {
            passwordField.text = ""
            wifiPopup.passwordRequested = false
            wifiPopup.showPassword = false
            wifiPopup.inlineError = ""
            wifiPopup.inlineInfo = qsTr("Connected to %1.").arg(ssid)
            Qt.inputMethod.hide()
        }

        function onConnectFailed(ssid, message, authError) {
            wifiPopup.inlineInfo = ""
            wifiPopup.inlineError = message
            if (authError && wifiPopup.selectedSsid === ssid) {
                // Kayıtlı profilin şifresi artık geçersiz olabilir: alanı aç,
                // metni seçili bırak ki kullanıcı doğrudan üzerine yazsın.
                wifiPopup.passwordRequested = true
                passwordField.forceActiveFocus()
                passwordField.selectAll()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 14

        // ---------------------------------------------------------- başlık
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "Wi-Fi"
                    font.pixelSize: 24
                    font.bold: true
                    color: UiStyle.textColor
                }

                Text {
                    Layout.fillWidth: true
                    text: wifiManager.statusText
                    font.pixelSize: 12
                    color: UiStyle.subtextColor
                    elide: Text.ElideRight
                }
            }

            ModernToggle {
                Layout.alignment: Qt.AlignVCenter
                checked: wifiManager.radioOn
                enabled: wifiManager.supported && !wifiManager.busy
                opacity: enabled ? 1.0 : 0.5

                onToggled: {
                    // Tıklama anında radioOn hâlâ eski değer, yani hedeflenen
                    // durum onun tersi. UiSettings.wireless bugüne kadar
                    // tanımlıydı ama hiç okunmuyordu - tercihi artık o tutuyor.
                    UiSettings.wireless = !wifiManager.radioOn
                    wifiManager.toggleRadio()
                }
            }

            // Yenile
            Rectangle {
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                Layout.alignment: Qt.AlignVCenter
                radius: 23
                color: refreshArea.pressed ? Qt.darker(UiStyle.roundButtonColor, 1.2)
                                           : UiStyle.roundButtonColor
                enabled: wifiPopup.bodyUsable && !wifiManager.scanning
                opacity: enabled ? 1.0 : 0.45

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: refreshGlyph
                    anchors.centerIn: parent
                    text: "⟳"
                    font.pixelSize: 22
                    color: UiStyle.textColor

                    // Bağımsız animasyon (`on rotation` değil): böylece rotation
                    // üzerindeki yazma hakkını kalıcı olarak gasp etmiyor ve
                    // durduğunda başlangıca döndürebiliyoruz.
                    RotationAnimator {
                        target: refreshGlyph
                        running: wifiManager.scanning
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite

                        onRunningChanged: if (!running) refreshGlyph.rotation = 0
                    }
                }

                MouseArea {
                    id: refreshArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: wifiManager.scan()
                }
            }

            // Kapat
            Rectangle {
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                Layout.alignment: Qt.AlignVCenter
                radius: 23
                color: closeArea.pressed ? Qt.darker(UiStyle.roundButtonColor, 1.2)
                                         : UiStyle.roundButtonColor

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 18
                    font.bold: true
                    color: UiStyle.textColor
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: wifiPopup.close()
                }
            }
        }

        // ------------------------------------------------- gövde: liste + detay
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16
            visible: wifiPopup.bodyUsable

            // Sol: görünen ağlar
            Rectangle {
                Layout.preferredWidth: wifiPopup.width * 0.44
                Layout.fillHeight: true
                color: UiStyle.innerCardColor
                radius: 16

                ListView {
                    id: networkList
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    spacing: 6
                    model: wifiManager.networks

                    delegate: WifiNetworkRow {
                        required property var model

                        width: ListView.view.width

                        ssid: model.ssid
                        signalStrength: model.signalStrength
                        bars: model.bars
                        security: model.security
                        secured: model.secured
                        enterprise: model.enterprise
                        active: model.active
                        saved: model.saved

                        selected: wifiPopup.selectedSsid === model.ssid
                        pending: wifiManager.busy && wifiManager.pendingSsid === model.ssid

                        onClicked: wifiPopup.selectNetwork(model.ssid, model.secured,
                                                           model.enterprise, model.security,
                                                           model.signalStrength)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 40
                    visible: wifiManager.networkCount === 0
                    text: wifiManager.scanning ? qsTr("Scanning for networks…") : qsTr("No networks found")
                    font.pixelSize: 14
                    color: UiStyle.subtextColor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }
            }

            // Sağ: seçili ağın detayı
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    text: wifiPopup.hasSelection ? wifiPopup.selectedSsid : qsTr("Select a network")
                    font.pixelSize: 20
                    font.bold: true
                    color: wifiPopup.hasSelection ? UiStyle.textColor : UiStyle.subtextColor
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: wifiPopup.hasSelection
                    text: {
                        var parts = []
                        parts.push(wifiPopup.selSecured ? wifiPopup.selSecurity : qsTr("Open network"))
                        if (wifiPopup.selSignal >= 0)
                            parts.push(qsTr("signal %1%").arg(wifiPopup.selSignal))
                        if (wifiPopup.selSaved)
                            parts.push(qsTr("saved"))
                        return parts.join(" · ")
                    }
                    font.pixelSize: 12
                    color: UiStyle.subtextColor
                    elide: Text.ElideRight
                }

                // Şifre alanı
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    visible: wifiPopup.hasSelection && wifiPopup.needsPassword
                    radius: 12
                    color: UiStyle.innerCardColor
                    border.width: 2
                    border.color: passwordField.activeFocus ? UiStyle.headerColor : UiStyle.transparent

                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 8
                        spacing: 6

                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            placeholderText: qsTr("Password")
                            placeholderTextColor: UiStyle.subtextColor
                            color: UiStyle.textColor
                            font.pixelSize: 16
                            selectByMouse: true
                            echoMode: wifiPopup.showPassword ? TextInput.Normal : TextInput.Password
                            background: Item {}

                            Keys.onReturnPressed: wifiPopup.doConnect()
                            Keys.onEnterPressed: wifiPopup.doConnect()
                        }

                        Rectangle {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignVCenter
                            radius: 10
                            color: showArea.pressed ? Qt.darker(UiStyle.roundButtonColor, 1.2)
                                                    : UiStyle.transparent
                            border.width: 1
                            border.color: UiStyle.roundButtonColor

                            Text {
                                anchors.centerIn: parent
                                text: wifiPopup.showPassword ? qsTr("Hide") : qsTr("Show")
                                font.pixelSize: 11
                                color: UiStyle.subtextColor
                            }

                            MouseArea {
                                id: showArea
                                anchors.fill: parent
                                onClicked: wifiPopup.showPassword = !wifiPopup.showPassword
                            }
                        }
                    }
                }

                // Kurumsal ağ uyarısı
                Text {
                    Layout.fillWidth: true
                    visible: wifiPopup.hasSelection && wifiPopup.selEnterprise
                    text: qsTr("Enterprise (802.1X) networks cannot be joined from this app.")
                    font.pixelSize: 12
                    color: UiStyle.subtextColor
                    wrapMode: Text.Wrap
                }

                // Eylemler
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: wifiPopup.hasSelection && !wifiPopup.selEnterprise

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: 26
                        enabled: !wifiManager.busy
                        opacity: enabled ? 1.0 : 0.5
                        color: primaryArea.pressed ? Qt.darker(UiStyle.headerColor, 1.15)
                                                   : UiStyle.headerColor

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: wifiManager.busy
                                    && wifiManager.pendingSsid === wifiPopup.selectedSsid
                                  ? qsTr("Please wait…")
                                  : (wifiPopup.selActive ? qsTr("Disconnect") : qsTr("Connect"))
                            font.pixelSize: 17
                            font.bold: true
                            color: UiStyle.onHeaderColor
                        }

                        MouseArea {
                            id: primaryArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (wifiPopup.selActive)
                                    wifiManager.disconnectCurrent()
                                else
                                    wifiPopup.doConnect()
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 52
                        visible: wifiPopup.selSaved
                        radius: 26
                        enabled: !wifiManager.busy
                        opacity: enabled ? 1.0 : 0.5
                        color: UiStyle.transparent
                        border.width: 1
                        border.color: UiStyle.roundButtonColor

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Forget")
                            font.pixelSize: 16
                            font.bold: true
                            color: UiStyle.textColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wifiPopup.doForget()
                        }
                    }
                }

                // Durum / hata satırı
                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    readonly property bool isError: wifiPopup.inlineError !== ""
                                                    || (wifiPopup.inlineInfo === ""
                                                        && wifiManager.lastError !== "")
                    text: wifiPopup.inlineError !== "" ? wifiPopup.inlineError
                        : (wifiPopup.inlineInfo !== "" ? wifiPopup.inlineInfo
                                                       : wifiManager.lastError)
                    color: isError ? UiStyle.red : UiStyle.buttonProgress
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }

                Item { Layout.fillHeight: true }
            }
        }

        // ------------------------------------------ kullanılamaz / radyo kapalı
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !wifiPopup.bodyUsable

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.8
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: wifiManager.supported ? qsTr("Wi-Fi is off") : qsTr("Wi-Fi unavailable")
                    font.pixelSize: 18
                    font.bold: true
                    color: UiStyle.textColor
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: wifiManager.supported
                          ? qsTr("Turn Wi-Fi on with the switch above to see networks.")
                          : wifiManager.statusText
                    font.pixelSize: 13
                    color: UiStyle.subtextColor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
