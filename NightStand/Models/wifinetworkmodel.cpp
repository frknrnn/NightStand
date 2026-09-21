#include "wifinetworkmodel.h"

#include <QHash>

#include <algorithm>

WifiNetworkModel::WifiNetworkModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int WifiNetworkModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_rows.count();
}

QVariant WifiNetworkModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_rows.count())
        return QVariant();

    const WifiNetwork &n = m_rows.at(index.row());

    switch (role) {
    case SsidRole:       return n.ssid;
    case SignalRole:     return n.signal;
    case BarsRole:       return barsFromSignal(n.signal);
    case SecurityRole:   return n.security;
    case SecuredRole:    return !n.security.isEmpty();
    case EnterpriseRole: return n.security.contains(QStringLiteral("802.1X"));
    case ActiveRole:     return n.active;
    case SavedRole:      return n.saved;
    default:             return QVariant();
    }
}

QHash<int, QByteArray> WifiNetworkModel::roleNames() const
{
    return {
        { SsidRole,       "ssid" },
        { SignalRole,     "signalStrength" },   // "signal" is a QML/Qt keyword, do not use it
        { BarsRole,       "bars" },
        { SecurityRole,   "security" },
        { SecuredRole,    "secured" },
        { EnterpriseRole, "enterprise" },
        { ActiveRole,     "active" },
        { SavedRole,      "saved" }
    };
}

void WifiNetworkModel::merge(const QList<WifiNetwork> &fresh)
{
    QHash<QString, int> freshBySsid;
    for (int i = 0; i < fresh.count(); ++i)
        freshBySsid.insert(fresh.at(i).ssid, i);

    // Drop rows that vanished. Walk backwards so the indices stay valid.
    for (int row = m_rows.count() - 1; row >= 0; --row) {
        if (freshBySsid.contains(m_rows.at(row).ssid))
            continue;
        beginRemoveRows(QModelIndex(), row, row);
        m_rows.removeAt(row);
        endRemoveRows();
    }

    // Update survivors in place. Order is deliberately left alone: the list must
    // not reshuffle under the user's finger because a neighbour's AP gained 3 dBm.
    for (int row = 0; row < m_rows.count(); ++row) {
        WifiNetwork &cur = m_rows[row];
        const WifiNetwork &next = fresh.at(freshBySsid.value(cur.ssid));

        if (cur.signal == next.signal && cur.security == next.security
            && cur.active == next.active && cur.saved == next.saved
            && cur.bssid == next.bssid) {
            continue;
        }

        cur.bssid = next.bssid;
        cur.signal = next.signal;
        cur.security = next.security;
        cur.active = next.active;
        cur.saved = next.saved;

        const QModelIndex idx = index(row, 0);
        emit dataChanged(idx, idx, { SignalRole, BarsRole, SecurityRole,
                                     SecuredRole, EnterpriseRole, ActiveRole, SavedRole });
    }

    // Append genuinely new SSIDs at the tail, in one block.
    QList<WifiNetwork> additions;
    for (const WifiNetwork &n : fresh) {
        if (indexOfSsid(n.ssid) < 0)
            additions.append(n);
    }
    if (!additions.isEmpty()) {
        const int first = m_rows.count();
        beginInsertRows(QModelIndex(), first, first + additions.count() - 1);
        m_rows.append(additions);
        endInsertRows();
    }
}

void WifiNetworkModel::reset(const QList<WifiNetwork> &fresh)
{
    QList<WifiNetwork> sorted = fresh;
    std::sort(sorted.begin(), sorted.end(), [](const WifiNetwork &a, const WifiNetwork &b) {
        if (a.active != b.active)
            return a.active;                // the network we are on always comes first
        if (a.signal != b.signal)
            return a.signal > b.signal;
        return a.ssid.localeAwareCompare(b.ssid) < 0;
    });

    beginResetModel();
    m_rows = sorted;
    endResetModel();
}

void WifiNetworkModel::applySaved(const QSet<QString> &savedSsids)
{
    for (int row = 0; row < m_rows.count(); ++row) {
        const bool saved = savedSsids.contains(m_rows.at(row).ssid);
        if (m_rows.at(row).saved == saved)
            continue;
        m_rows[row].saved = saved;
        const QModelIndex idx = index(row, 0);
        emit dataChanged(idx, idx, { SavedRole });
    }
}

void WifiNetworkModel::clear()
{
    if (m_rows.isEmpty())
        return;
    beginResetModel();
    m_rows.clear();
    endResetModel();
}

int WifiNetworkModel::indexOfSsid(const QString &ssid) const
{
    for (int i = 0; i < m_rows.count(); ++i) {
        if (m_rows.at(i).ssid == ssid)
            return i;
    }
    return -1;
}

WifiNetwork WifiNetworkModel::networkAt(int row) const
{
    if (row < 0 || row >= m_rows.count())
        return WifiNetwork();
    return m_rows.at(row);
}

int WifiNetworkModel::barsFromSignal(int signalPercent)
{
    if (signalPercent <= 0)
        return 0;
    if (signalPercent < 30)
        return 1;
    if (signalPercent < 55)
        return 2;
    if (signalPercent < 75)
        return 3;
    return 4;
}
