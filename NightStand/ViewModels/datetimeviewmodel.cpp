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
    // The default locale is owned by LanguageManager, which calls
    // QLocale::setDefault() on every switch. This used to hard-code
    // QLocale::Turkish, so the dashboard date stayed Turkish whatever
    // language was selected.
    return QLocale().toString(m_model->currentDateTime().date(), "dd MMMM yyyy");
}

QString DateTimeViewModel::dayOfWeek() const
{
    return QLocale().toString(m_model->currentDateTime().date(), "dddd");
}

void DateTimeViewModel::updateDateTime()
{
    m_model->setCurrentDateTime(QDateTime::currentDateTime());

    emit currentTimeChanged();
    emit currentDateChanged();
    emit dayOfWeekChanged();
}
