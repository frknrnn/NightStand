#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "../ViewModels/datetimeviewmodel.h"
#include "../ViewModels/todoviewmodel.h"
#include "../ViewModels/alarmviewmodel.h"

class AppController : public QObject
{
    Q_OBJECT
public:
    explicit AppController(QObject *parent = nullptr);
    DateTimeViewModel *getDateTimeViewModel() { return dateTimeViewModel; }
    TodoViewModel *getTodoViewModel() { return todoViewModel; }
    AlarmViewModel *getAlarmViewModel() { return alarmViewModel; }


private:
    DateTimeViewModel *dateTimeViewModel;
    TodoViewModel *todoViewModel;
    AlarmViewModel *alarmViewModel;

signals:
};

#endif // APPCONTROLLER_H
