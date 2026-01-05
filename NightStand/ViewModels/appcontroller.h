#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "../ViewModels/datetimeviewmodel.h"
#include "../ViewModels/todoviewmodel.h"

class AppController : public QObject
{
    Q_OBJECT
public:
    explicit AppController(QObject *parent = nullptr);
    DateTimeViewModel *getDateTimeViewModel() { return dateTimeViewModel; }
    TodoViewModel *getTodoViewModel() { return todoViewModel; }


private:
    DateTimeViewModel *dateTimeViewModel;
    TodoViewModel *todoViewModel;

signals:
};

#endif // APPCONTROLLER_H
