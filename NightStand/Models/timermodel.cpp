#include "timermodel.h"
#include "storageservice.h"

#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QVariantMap>
#include <QDebug>

TimerModel::TimerModel(QObject *parent)
    : QObject(parent)
{
    m_ticker.setTimerType(Qt::PreciseTimer);
    connect(&m_ticker, &QTimer::timeout, this, &TimerModel::onTick);

    m_alertTimeout.setSingleShot(true);
    connect(&m_alertTimeout, &QTimer::timeout, this, [this]() { dismissAlert(); });

    loadFromStorage();
}

// ---------------------------------------------------------------- queries

qint64 TimerModel::remainingMs() const
{
    if (m_state != Running)
        return m_remainingMs;

    return qMax<qint64>(0, m_remainingAtStartMs - m_elapsed.elapsed());
}

int TimerModel::remainingSeconds() const
{
    // ceil, so "05:00" shows at t=0 and "00:00" exactly at expiry
    return static_cast<int>((remainingMs() + 999) / 1000);
}

QString TimerModel::presetLabel(qint64 ms)
{
    const int minutes = static_cast<int>(ms / 60000);
    if (minutes > 0)
        return QStringLiteral("%1 min").arg(minutes);

    return QStringLiteral("%1 sec").arg(static_cast<int>(ms / 1000));
}

QVariantList TimerModel::presets() const
{
    QVariantList list;
    list.reserve(m_presetMs.size());

    for (qint64 ms : m_presetMs) {
        QVariantMap entry;
        entry.insert(QStringLiteral("ms"), ms);
        entry.insert(QStringLiteral("label"), presetLabel(ms));
        list.append(entry);
    }

    return list;
}

// ---------------------------------------------------------------- internals

void TimerModel::setState(State s)
{
    if (m_state == s)
        return;

    m_state = s;
    emit stateChanged();
}

void TimerModel::setAlerting(bool on)
{
    if (m_alerting == on)
        return;

    m_alerting = on;
    emit alertingChanged();
}

void TimerModel::emitRemaining()
{
    emit remainingMsChanged();

    const int s = remainingSeconds();
    if (s != m_lastEmittedSeconds) {
        m_lastEmittedSeconds = s;
        emit remainingSecondsChanged();
    }
}

void TimerModel::refreshEndsAt()
{
    const QDateTime next = (m_state == Running)
                               ? QDateTime::currentDateTime().addMSecs(remainingMs())
                               : QDateTime();

    if (m_endWallClock == next)
        return;

    m_endWallClock = next;
    emit endsAtChanged();
}

void TimerModel::finish()
{
    m_ticker.stop();
    m_remainingMs = 0;
    setState(Finished);
    refreshEndsAt();
    emitRemaining();

    setAlerting(true);
    m_alertTimeout.start(kAlertTimeoutMs);

    emit finished();
    saveToStorage();
}

void TimerModel::onTick()
{
    emitRemaining();

    if (remainingMs() <= 0)
        finish();
}

// ---------------------------------------------------------------- commands

void TimerModel::setSelectedDurationMs(qint64 ms)
{
    ms = qBound<qint64>(0, ms, 24LL * 3600 * 1000);

    if (m_selectedDurationMs == ms)
        return;

    m_selectedDurationMs = ms;
    emit selectedDurationMsChanged();
    saveToStorage();
}

void TimerModel::start()
{
    if (m_selectedDurationMs <= 0)
        return;

    setAlerting(false);
    m_alertTimeout.stop();

    m_totalMs = m_selectedDurationMs;
    emit totalMsChanged();

    m_remainingAtStartMs = m_totalMs;
    m_elapsed.start();
    m_ticker.start(kTickMs);

    setState(Running);
    refreshEndsAt();
    emitRemaining();
    saveToStorage();
}

void TimerModel::pause()
{
    if (m_state != Running)
        return;

    m_remainingMs = remainingMs();   // freeze exactly
    m_ticker.stop();

    setState(Paused);
    refreshEndsAt();
    emitRemaining();
    saveToStorage();
}

void TimerModel::resume()
{
    if (m_state != Paused || m_remainingMs <= 0)
        return;

    m_remainingAtStartMs = m_remainingMs;
    m_elapsed.start();
    m_ticker.start(kTickMs);

    setState(Running);
    refreshEndsAt();
    emitRemaining();
    saveToStorage();
}

void TimerModel::cancel()
{
    m_ticker.stop();
    m_alertTimeout.stop();
    setAlerting(false);

    m_totalMs = 0;
    m_remainingMs = 0;
    m_remainingAtStartMs = 0;

    emit totalMsChanged();
    setState(Idle);
    refreshEndsAt();
    emitRemaining();

    // m_selectedDurationMs is deliberately preserved: the picker comes back
    // showing the same duration, so restarting is a single tap.
    saveToStorage();
}

void TimerModel::addMinutes(int minutes)
{
    if (m_state != Running && m_state != Paused)
        return;

    const qint64 delta = static_cast<qint64>(minutes) * 60000;

    m_totalMs += delta;              // keeps progress = remaining/total meaningful
    if (m_state == Running)
        m_remainingAtStartMs += delta;
    else
        m_remainingMs += delta;

    emit totalMsChanged();
    refreshEndsAt();
    emitRemaining();
    saveToStorage();
}

void TimerModel::applyPreset(int index)
{
    if (index < 0 || index >= m_presetMs.size())
        return;

    setSelectedDurationMs(m_presetMs.at(index));
}

void TimerModel::dismissAlert()
{
    m_alertTimeout.stop();
    cancel();
}

// ---------------------------------------------------------------- persistence

void TimerModel::loadFromStorage()
{
    const QJsonObject obj = StorageService::instance()->loadTimer();

    if (obj.isEmpty())
        return;

    if (obj.contains(QStringLiteral("lastDurationMs"))) {
        const qint64 ms = static_cast<qint64>(obj.value(QStringLiteral("lastDurationMs")).toDouble());
        if (ms > 0)
            m_selectedDurationMs = qBound<qint64>(0, ms, 24LL * 3600 * 1000);
    }

    const QJsonArray storedPresets = obj.value(QStringLiteral("presetsMs")).toArray();
    if (!storedPresets.isEmpty()) {
        QList<qint64> loaded;
        for (const QJsonValue &v : storedPresets) {
            const qint64 ms = static_cast<qint64>(v.toDouble());
            if (ms > 0)
                loaded.append(ms);
        }
        if (!loaded.isEmpty())
            m_presetMs = loaded;
    }

    // Restore a countdown that was still running when the app closed.
    if (obj.value(QStringLiteral("state")).toString() == QStringLiteral("running")) {
        const qint64 deadline = static_cast<qint64>(obj.value(QStringLiteral("deadlineEpochMs")).toDouble());
        const qint64 left = deadline - QDateTime::currentMSecsSinceEpoch();

        if (deadline > 0 && left > 500) {
            m_totalMs = static_cast<qint64>(obj.value(QStringLiteral("totalMs")).toDouble());
            if (m_totalMs < left)
                m_totalMs = left;

            m_remainingAtStartMs = left;
            m_elapsed.start();
            m_ticker.start(kTickMs);
            m_state = Running;
            refreshEndsAt();
        }
        // Expired while the app was down: stay Idle and deliberately do NOT
        // raise the alert - beeping at boot for a timer that ended days ago
        // is worse than losing it.
    }

    m_lastEmittedSeconds = remainingSeconds();
}

void TimerModel::saveToStorage()
{
    QJsonObject obj;
    obj.insert(QStringLiteral("lastDurationMs"), static_cast<double>(m_selectedDurationMs));

    QJsonArray presetArray;
    for (qint64 ms : m_presetMs)
        presetArray.append(static_cast<double>(ms));
    obj.insert(QStringLiteral("presetsMs"), presetArray);

    if (m_state == Running) {
        obj.insert(QStringLiteral("state"), QStringLiteral("running"));
        obj.insert(QStringLiteral("totalMs"), static_cast<double>(m_totalMs));
        obj.insert(QStringLiteral("deadlineEpochMs"),
                   static_cast<double>(QDateTime::currentMSecsSinceEpoch() + remainingMs()));
    } else {
        obj.insert(QStringLiteral("state"), QStringLiteral("idle"));
    }

    StorageService::instance()->saveTimer(obj);
}
