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
    Q_PROPERTY(bool flashMode READ flashMode WRITE setFlashMode NOTIFY flashModeChanged)

public:
    explicit AppController(QObject *parent = nullptr);
    DateTimeViewModel *getDateTimeViewModel() { return dateTimeViewModel; }
    TodoViewModel *getTodoViewModel() { return todoViewModel; }
    AlarmViewModel *getAlarmViewModel() { return alarmViewModel; }

    bool nightMode() const { return m_nightMode; }
    void setNightMode(bool enabled);
    Q_INVOKABLE void toggleNightMode();

    bool flashMode() const { return m_flashMode; }
    void setFlashMode(bool enabled);
    Q_INVOKABLE void toggleFlashMode();

private:
    DateTimeViewModel *dateTimeViewModel;
    TodoViewModel *todoViewModel;
    AlarmViewModel *alarmViewModel;
    bool m_nightMode = false;
    bool m_flashMode = false;

signals:
    void nightModeChanged();
    void flashModeChanged();
};

#endif // APPCONTROLLER_H
