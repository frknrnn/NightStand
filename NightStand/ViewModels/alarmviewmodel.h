#ifndef ALARMVIEWMODEL_H
#define ALARMVIEWMODEL_H

#include <QObject>
#include "../Models/alarmmodel.h"

class AlarmViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractListModel* alarmModel READ alarmModel CONSTANT)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int enabledCount READ enabledCount NOTIFY enabledCountChanged)

public:
    explicit AlarmViewModel(QObject *parent = nullptr);

    QAbstractListModel* alarmModel() const;

    int totalCount() const;
    int enabledCount() const;

    // QML invokable methods
    Q_INVOKABLE void addAlarm(int hour, int minute, const QString &label = QString());
    Q_INVOKABLE void removeAlarm(int id);
    Q_INVOKABLE void toggleEnabled(int id);
    Q_INVOKABLE void updateAlarm(int id, int hour, int minute, const QString &label);
    Q_INVOKABLE void setRepeatDays(int id, const QVariantList &days);

signals:
    void totalCountChanged();
    void enabledCountChanged();

private slots:
    void onAlarmCountChanged();
    void onEnabledCountChanged();

private:
    AlarmModel *m_model;
};

#endif // ALARMVIEWMODEL_H
