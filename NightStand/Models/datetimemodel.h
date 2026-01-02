#ifndef DATETIMEMODEL_H
#define DATETIMEMODEL_H

#include <QObject>
#include <QDateTime>

class DateTimeModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime currentDateTime READ currentDateTime NOTIFY currentDateTimeChanged)

public:
    explicit DateTimeModel(QObject *parent = nullptr);

    QDateTime currentDateTime() const;
    void setCurrentDateTime(const QDateTime &dateTime);

signals:
    void currentDateTimeChanged();

private:
    QDateTime m_currentDateTime;
};

#endif // DATETIMEMODEL_H
