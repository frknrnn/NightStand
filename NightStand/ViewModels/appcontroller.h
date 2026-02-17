#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "../ViewModels/datetimeviewmodel.h"
#include "../ViewModels/todoviewmodel.h"
#include "../ViewModels/alarmviewmodel.h"

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool nightMode READ nightMode WRITE setNightMode NOTIFY nightModeChanged)

public:
    explicit AppController(QObject *parent = nullptr);
    DateTimeViewModel *getDateTimeViewModel() { return dateTimeViewModel; }
    TodoViewModel *getTodoViewModel() { return todoViewModel; }
    AlarmViewModel *getAlarmViewModel() { return alarmViewModel; }

    bool nightMode() const { return m_nightMode; }
    void setNightMode(bool enabled);
    Q_INVOKABLE void toggleNightMode();

private:
    DateTimeViewModel *dateTimeViewModel;
    TodoViewModel *todoViewModel;
    AlarmViewModel *alarmViewModel;
    bool m_nightMode = false;

signals:
    void nightModeChanged();
};

#endif // APPCONTROLLER_H
