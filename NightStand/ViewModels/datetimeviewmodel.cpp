#include "datetimeviewmodel.h"
#include <QLocale>
#include "../Models/modelmanager.h"

DateTimeViewModel::DateTimeViewModel(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
{
    m_model = ModelManager::instance()->GetDateTimeModel();
    connect(m_timer, &QTimer::timeout, this, &DateTimeViewModel::updateDateTime);
    m_timer->start(1000);
    updateDateTime();
}

QString DateTimeViewModel::currentTime() const
{
    return m_model->currentDateTime().time().toString("HH:mm:ss");
}

QString DateTimeViewModel::currentDate() const
{
    QLocale locale(QLocale::Turkish);
    return locale.toString(m_model->currentDateTime().date(), "dd MMMM yyyy");
}

QString DateTimeViewModel::dayOfWeek() const
{
    QLocale locale(QLocale::Turkish);
    return locale.toString(m_model->currentDateTime().date(), "dddd");
}

void DateTimeViewModel::updateDateTime()
{
    m_model->setCurrentDateTime(QDateTime::currentDateTime());

    emit currentTimeChanged();
    emit currentDateChanged();
    emit dayOfWeekChanged();
}
