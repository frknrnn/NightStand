#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject{parent}
    , m_nightMode(false)
{
    dateTimeViewModel = new DateTimeViewModel();
    todoViewModel = new TodoViewModel();
    alarmViewModel = new AlarmViewModel();
}

void AppController::setNightMode(bool enabled)
{
    if (m_nightMode != enabled) {
        m_nightMode = enabled;
        emit nightModeChanged();
    }
}

void AppController::toggleNightMode()
{
    setNightMode(!m_nightMode);
}
