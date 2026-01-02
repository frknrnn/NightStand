#ifndef DATETIMEVIEWMODEL_H
#define DATETIMEVIEWMODEL_H

#include <QObject>
#include <QTimer>
#include "../Models/datetimemodel.h"

class DateTimeViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentTime READ currentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QString currentDate READ currentDate NOTIFY currentDateChanged)
    Q_PROPERTY(QString dayOfWeek READ dayOfWeek NOTIFY dayOfWeekChanged)

public:
    explicit DateTimeViewModel(QObject *parent = nullptr);

    QString currentTime() const;
    QString currentDate() const;
    QString dayOfWeek() const;

signals:
    void currentTimeChanged();
    void currentDateChanged();
    void dayOfWeekChanged();

private slots:
    void updateDateTime();

private:
    DateTimeModel *m_model;
    QTimer *m_timer;
};

#endif // DATETIMEVIEWMODEL_H
