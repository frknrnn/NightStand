#include "datetimemodel.h"

DateTimeModel::DateTimeModel(QObject *parent)
    : QObject(parent)
    , m_currentDateTime(QDateTime::currentDateTime())
{
}

QDateTime DateTimeModel::currentDateTime() const
{
    return m_currentDateTime;
}

void DateTimeModel::setCurrentDateTime(const QDateTime &dateTime)
{
    if (m_currentDateTime != dateTime) {
        m_currentDateTime = dateTime;
        emit currentDateTimeChanged();
    }
}
