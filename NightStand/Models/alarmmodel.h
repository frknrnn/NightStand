#ifndef ALARMMODEL_H
#define ALARMMODEL_H

#include <QAbstractListModel>
#include <QTime>
#include <QJsonArray>
#include <QJsonObject>

struct AlarmItem {
    int id;
    QTime time;
    QString label;
    bool enabled;
    QList<int> repeatDays; // 0=Sun, 1=Mon, ..., 6=Sat

    // JSON serialization
    QJsonObject toJson() const;
    static AlarmItem fromJson(const QJsonObject &json);
};

class AlarmModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum AlarmRoles {
        IdRole = Qt::UserRole + 1,
        TimeRole,
        TimeStringRole,
        LabelRole,
        EnabledRole,
        RepeatDaysRole
    };

    explicit AlarmModel(QObject *parent = nullptr);

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Alarm operations
    Q_INVOKABLE void addAlarm(int hour, int minute, const QString &label = QString());
    Q_INVOKABLE void removeAlarm(int id);
    Q_INVOKABLE void toggleEnabled(int id);
    Q_INVOKABLE void updateAlarm(int id, int hour, int minute, const QString &label);
    Q_INVOKABLE void setRepeatDays(int id, const QVariantList &days);

    // Persistence
    void loadFromStorage();
    void saveToStorage();

    // Getters
    QList<AlarmItem> alarms() const;
    int alarmCount() const;
    int enabledCount() const;

signals:
    void alarmCountChanged();
    void enabledCountChanged();

private:
    QList<AlarmItem> m_alarms;
    int m_nextId;

    int findAlarmIndex(int id) const;
    QString formatTime(const QTime &time) const;
};

#endif // ALARMMODEL_H
