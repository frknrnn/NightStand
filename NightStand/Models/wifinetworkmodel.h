#ifndef WIFINETWORKMODEL_H
#define WIFINETWORKMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QSet>
#include <QString>

// A single visible access point, already de-duplicated by SSID.
struct WifiNetwork {
    QString ssid;
    QString bssid;      // strongest BSSID seen for this SSID (repeaters report several)
    int signal = 0;     // 0-100, as nmcli reports it
    QString security;   // "" = open, e.g. "WPA2", "WPA1 WPA2", "WPA3", "WEP", "802.1X"
    bool active = false;
    bool saved = false;
};

class WifiNetworkModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum WifiRoles {
        SsidRole = Qt::UserRole + 1,
        SignalRole,       // 0-100
        BarsRole,         // 0-4. The bucket math lives here, not in QML.
        SecurityRole,     // raw nmcli string, for the subtitle line
        SecuredRole,      // security is not empty
        EnterpriseRole,   // 802.1X - a plain password cannot authenticate these
        ActiveRole,       // this is the network we are on right now
        SavedRole         // a NetworkManager profile already exists
    };

    explicit WifiNetworkModel(QObject *parent = nullptr);

    // Read-only model: unlike TodoModel there is no setData()/flags(). Every
    // mutation comes from nmcli through WifiManager.
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Periodic refresh. Keeps row order untouched so the list never jumps while
    // the user is reading it - only signal/security/active/saved move.
    void merge(const QList<WifiNetwork> &fresh);

    // User-triggered scan: full reset, re-sorted (active first, then signal desc).
    void reset(const QList<WifiNetwork> &fresh);

    // The saved-profile query runs on its own schedule, so it lands separately.
    void applySaved(const QSet<QString> &savedSsids);

    void clear();
    bool isEmpty() const { return m_rows.isEmpty(); }
    int indexOfSsid(const QString &ssid) const;
    WifiNetwork networkAt(int row) const;

    static int barsFromSignal(int signalPercent);

private:
    QList<WifiNetwork> m_rows;
};

#endif // WIFINETWORKMODEL_H
