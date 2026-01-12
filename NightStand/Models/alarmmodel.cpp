#include "alarmmodel.h"
#include "storageservice.h"

// AlarmItem JSON serialization
QJsonObject AlarmItem::toJson() const
{
    QJsonObject json;
    json["id"] = id;
    json["time"] = time.toString("HH:mm");
    json["label"] = label;
    json["enabled"] = enabled;

    QJsonArray daysArray;
    for (int day : repeatDays) {
        daysArray.append(day);
    }
    json["repeatDays"] = daysArray;

    return json;
}

AlarmItem AlarmItem::fromJson(const QJsonObject &json)
{
    AlarmItem item;
    item.id = json["id"].toInt();
    item.time = QTime::fromString(json["time"].toString(), "HH:mm");
    item.label = json["label"].toString();
    item.enabled = json["enabled"].toBool();

    QJsonArray daysArray = json["repeatDays"].toArray();
    for (const QJsonValue &value : daysArray) {
        item.repeatDays.append(value.toInt());
    }

    return item;
}

AlarmModel::AlarmModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_nextId(1)
{
    loadFromStorage();
}

int AlarmModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_alarms.count();
}

QVariant AlarmModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_alarms.count())
        return QVariant();

    const AlarmItem &item = m_alarms.at(index.row());

    switch (role) {
    case IdRole:
        return item.id;
    case TimeRole:
        return item.time;
    case TimeStringRole:
        return formatTime(item.time);
    case LabelRole:
        return item.label;
    case EnabledRole:
        return item.enabled;
    case RepeatDaysRole:
        return QVariant::fromValue(item.repeatDays);
    default:
        return QVariant();
    }
}

bool AlarmModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_alarms.count())
        return false;

    AlarmItem &item = m_alarms[index.row()];

    switch (role) {
    case LabelRole:
        item.label = value.toString();
        break;
    case EnabledRole:
        item.enabled = value.toBool();
        emit enabledCountChanged();
        break;
    default:
        return false;
    }

    emit dataChanged(index, index, {role});
    saveToStorage();
    return true;
}

Qt::ItemFlags AlarmModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;
    return Qt::ItemIsEditable | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> AlarmModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "alarmId";
    roles[TimeRole] = "time";
    roles[TimeStringRole] = "timeString";
    roles[LabelRole] = "label";
    roles[EnabledRole] = "enabled";
    roles[RepeatDaysRole] = "repeatDays";
    return roles;
}

void AlarmModel::addAlarm(int hour, int minute, const QString &label)
{
    AlarmItem item;
    item.id = m_nextId++;
    item.time = QTime(hour, minute);
    item.label = label.isEmpty() ? "Alarm" : label.trimmed();
    item.enabled = true;

    beginInsertRows(QModelIndex(), m_alarms.count(), m_alarms.count());
    m_alarms.append(item);
    endInsertRows();

    emit alarmCountChanged();
    emit enabledCountChanged();
    saveToStorage();
}

void AlarmModel::removeAlarm(int id)
{
    int index = findAlarmIndex(id);
    if (index < 0)
        return;

    bool wasEnabled = m_alarms.at(index).enabled;

    beginRemoveRows(QModelIndex(), index, index);
    m_alarms.removeAt(index);
    endRemoveRows();

    emit alarmCountChanged();
    if (wasEnabled)
        emit enabledCountChanged();
    saveToStorage();
}

void AlarmModel::toggleEnabled(int id)
{
    int index = findAlarmIndex(id);
    if (index < 0)
        return;

    m_alarms[index].enabled = !m_alarms[index].enabled;

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {EnabledRole});
    emit enabledCountChanged();
    saveToStorage();
}

void AlarmModel::updateAlarm(int id, int hour, int minute, const QString &label)
{
    int index = findAlarmIndex(id);
    if (index < 0)
        return;

    m_alarms[index].time = QTime(hour, minute);
    m_alarms[index].label = label.trimmed();

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {TimeRole, TimeStringRole, LabelRole});
    saveToStorage();
}

void AlarmModel::setRepeatDays(int id, const QVariantList &days)
{
    int index = findAlarmIndex(id);
    if (index < 0)
        return;

    m_alarms[index].repeatDays.clear();
    for (const QVariant &day : days) {
        m_alarms[index].repeatDays.append(day.toInt());
    }

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {RepeatDaysRole});
    saveToStorage();
}

QList<AlarmItem> AlarmModel::alarms() const
{
    return m_alarms;
}

int AlarmModel::alarmCount() const
{
    return m_alarms.count();
}

int AlarmModel::enabledCount() const
{
    int count = 0;
    for (const AlarmItem &item : m_alarms) {
        if (item.enabled)
            ++count;
    }
    return count;
}

int AlarmModel::findAlarmIndex(int id) const
{
    for (int i = 0; i < m_alarms.count(); ++i) {
        if (m_alarms.at(i).id == id)
            return i;
    }
    return -1;
}

QString AlarmModel::formatTime(const QTime &time) const
{
    return time.toString("HH:mm");
}

void AlarmModel::loadFromStorage()
{
    QJsonArray alarmsArray = StorageService::instance()->loadAlarms();

    if (alarmsArray.isEmpty()) {
        return;
    }

    beginResetModel();
    m_alarms.clear();
    m_nextId = 1;

    for (const QJsonValue &value : alarmsArray) {
        if (value.isObject()) {
            AlarmItem item = AlarmItem::fromJson(value.toObject());
            m_alarms.append(item);
            if (item.id >= m_nextId) {
                m_nextId = item.id + 1;
            }
        }
    }

    endResetModel();
    emit alarmCountChanged();
    emit enabledCountChanged();
}

void AlarmModel::saveToStorage()
{
    QJsonArray alarmsArray;

    for (const AlarmItem &item : m_alarms) {
        alarmsArray.append(item.toJson());
    }

    StorageService::instance()->saveAlarms(alarmsArray);
}
