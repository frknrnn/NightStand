#include "timerviewmodel.h"
#include "../Models/modelmanager.h"

TimerViewModel::TimerViewModel(QObject *parent)
    : QObject(parent)
{
    m_model = ModelManager::instance()->GetTimerModel();

    // Pure signal->signal relays: the cheapest possible forwarding.
    connect(m_model, &TimerModel::stateChanged, this, &TimerViewModel::stateChanged);
    connect(m_model, &TimerModel::remainingMsChanged, this, &TimerViewModel::remainingMsChanged);
    connect(m_model, &TimerModel::remainingSecondsChanged, this, &TimerViewModel::remainingSecondsChanged);
    connect(m_model, &TimerModel::totalMsChanged, this, &TimerViewModel::totalMsChanged);
    connect(m_model, &TimerModel::selectedDurationMsChanged, this, &TimerViewModel::selectedDurationChanged);
    connect(m_model, &TimerModel::presetsChanged, this, &TimerViewModel::presetsChanged);
    connect(m_model, &TimerModel::alertingChanged, this, &TimerViewModel::alertingChanged);
    connect(m_model, &TimerModel::endsAtChanged, this, &TimerViewModel::endsAtChanged);
}

// ---------------------------------------------------------------- state

int TimerViewModel::timerState() const { return static_cast<int>(m_model->state()); }
bool TimerViewModel::idle() const { return m_model->state() == TimerModel::Idle; }
bool TimerViewModel::running() const { return m_model->state() == TimerModel::Running; }
bool TimerViewModel::paused() const { return m_model->state() == TimerModel::Paused; }
bool TimerViewModel::finished() const { return m_model->state() == TimerModel::Finished; }
bool TimerViewModel::active() const { return !idle(); }

// ---------------------------------------------------------------- display

qreal TimerViewModel::progress() const
{
    const qint64 total = m_model->totalMs();
    if (total <= 0)
        return 0.0;

    return static_cast<qreal>(m_model->remainingMs()) / static_cast<qreal>(total);
}

QString TimerViewModel::formatMs(qint64 ms) const
{
    if (ms < 0)
        ms = 0;

    const int totalSeconds = static_cast<int>((ms + 999) / 1000);
    const int h = totalSeconds / 3600;
    const int m = (totalSeconds % 3600) / 60;
    const int s = totalSeconds % 60;

    if (h > 0) {
        return QStringLiteral("%1:%2:%3")
            .arg(h)
            .arg(m, 2, 10, QLatin1Char('0'))
            .arg(s, 2, 10, QLatin1Char('0'));
    }

    return QStringLiteral("%1:%2")
        .arg(m, 2, 10, QLatin1Char('0'))
        .arg(s, 2, 10, QLatin1Char('0'));
}

QString TimerViewModel::remainingText() const
{
    return formatMs(m_model->remainingMs());
}

bool TimerViewModel::showsHours() const
{
    return m_model->remainingSeconds() >= 3600;
}

QString TimerViewModel::totalText() const
{
    return formatMs(m_model->totalMs());
}

QString TimerViewModel::endsAtText() const
{
    const QDateTime endsAt = m_model->endsAt();
    if (!endsAt.isValid())
        return QString();

    return endsAt.toString(QStringLiteral("HH:mm"));
}

// ---------------------------------------------------------------- selection

int TimerViewModel::selectedHours() const
{
    return static_cast<int>(m_model->selectedDurationMs() / 3600000);
}

int TimerViewModel::selectedMinutes() const
{
    return static_cast<int>((m_model->selectedDurationMs() % 3600000) / 60000);
}

int TimerViewModel::selectedSeconds() const
{
    return static_cast<int>((m_model->selectedDurationMs() % 60000) / 1000);
}

bool TimerViewModel::canStart() const
{
    return m_model->selectedDurationMs() > 0;
}

QVariantList TimerViewModel::presets() const { return m_model->presets(); }
bool TimerViewModel::alerting() const { return m_model->alerting(); }

// ---------------------------------------------------------------- commands

void TimerViewModel::setSelectedDuration(int hours, int minutes, int seconds)
{
    const qint64 ms = static_cast<qint64>(hours) * 3600000
                      + static_cast<qint64>(minutes) * 60000
                      + static_cast<qint64>(seconds) * 1000;

    m_model->setSelectedDurationMs(ms);
}

void TimerViewModel::applyPreset(int index) { m_model->applyPreset(index); }
void TimerViewModel::start() { m_model->start(); }
void TimerViewModel::pause() { m_model->pause(); }
void TimerViewModel::resume() { m_model->resume(); }
void TimerViewModel::cancel() { m_model->cancel(); }
void TimerViewModel::addOneMinute() { m_model->addMinutes(1); }
void TimerViewModel::dismissAlert() { m_model->dismissAlert(); }

void TimerViewModel::toggleStartPause()
{
    switch (m_model->state()) {
    case TimerModel::Idle:     m_model->start();        break;
    case TimerModel::Running:  m_model->pause();        break;
    case TimerModel::Paused:   m_model->resume();       break;
    case TimerModel::Finished: m_model->dismissAlert(); break;
    }
}
