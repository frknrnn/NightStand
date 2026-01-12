#include "alarmviewmodel.h"
#include "../Models/modelmanager.h"

AlarmViewModel::AlarmViewModel(QObject *parent)
    : QObject(parent)
{
    m_model = ModelManager::instance()->GetAlarmModel();
    connect(m_model, &AlarmModel::alarmCountChanged, this, &AlarmViewModel::onAlarmCountChanged);
    connect(m_model, &AlarmModel::enabledCountChanged, this, &AlarmViewModel::onEnabledCountChanged);
}

QAbstractListModel* AlarmViewModel::alarmModel() const
{
    return m_model;
}

int AlarmViewModel::totalCount() const
{
    return m_model->alarmCount();
}

int AlarmViewModel::enabledCount() const
{
    return m_model->enabledCount();
}

void AlarmViewModel::addAlarm(int hour, int minute, const QString &label)
{
    m_model->addAlarm(hour, minute, label);
}

void AlarmViewModel::removeAlarm(int id)
{
    m_model->removeAlarm(id);
}

void AlarmViewModel::toggleEnabled(int id)
{
    m_model->toggleEnabled(id);
}

void AlarmViewModel::updateAlarm(int id, int hour, int minute, const QString &label)
{
    m_model->updateAlarm(id, hour, minute, label);
}

void AlarmViewModel::setRepeatDays(int id, const QVariantList &days)
{
    m_model->setRepeatDays(id, days);
}

void AlarmViewModel::onAlarmCountChanged()
{
    emit totalCountChanged();
}

void AlarmViewModel::onEnabledCountChanged()
{
    emit enabledCountChanged();
}
