#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject{parent}
{
    dateTimeViewModel = new DateTimeViewModel();
    todoViewModel = new TodoViewModel();
}
