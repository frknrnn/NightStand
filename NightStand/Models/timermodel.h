#ifndef TIMERMODEL_H
#define TIMERMODEL_H

#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <QDateTime>
#include <QVariantList>
#include <QList>

class TimerModel : public QObject
{
    Q_OBJECT
public:
    enum State {
        Idle = 0,
        Running = 1,
        Paused = 2,
        Finished = 3
    };
    Q_ENUM(State)

    explicit TimerModel(QObject *parent = nullptr);

    State state() const { return m_state; }
    qint64 totalMs() const { return m_totalMs; }
    qint64 remainingMs() const;
    int remainingSeconds() const;

    qint64 selectedDurationMs() const { return m_selectedDurationMs; }
    void setSelectedDurationMs(qint64 ms);

    QVariantList presets() const;
    bool alerting() const { return m_alerting; }
    QDateTime endsAt() const { return m_endWallClock; }

    // Commands
    void start();
    void pause();
    void resume();
    void cancel();
    void addMinutes(int minutes);
    void applyPreset(int index);
    void dismissAlert();

    void loadFromStorage();
    void saveToStorage();

signals:
    void stateChanged();
    void totalMsChanged();
    void remainingMsChanged();        // every tick (~20 Hz) - ring only
    void remainingSecondsChanged();   // only when the displayed second changes
    void selectedDurationMsChanged();
    void presetsChanged();
    void alertingChanged();
    void endsAtChanged();
    void finished();

private slots:
    void onTick();

private:
    void setState(State s);
    void setAlerting(bool on);
    void finish();
    void emitRemaining();
    void refreshEndsAt();
    static QString presetLabel(qint64 ms);

    static constexpr int kTickMs = 50;            // 20 Hz
    static constexpr int kAlertTimeoutMs = 60000; // auto-silence after 60 s

    State m_state = Idle;
    qint64 m_totalMs = 0;              // duration of the run in flight (grows with +1 min)
    qint64 m_remainingMs = 0;          // authoritative while NOT Running
    qint64 m_remainingAtStartMs = 0;   // remaining at last start()/resume()/addMinutes()
    qint64 m_selectedDurationMs = 5 * 60 * 1000;
    int m_lastEmittedSeconds = -1;
    bool m_alerting = false;
    QDateTime m_endWallClock;

    QElapsedTimer m_elapsed;           // monotonic - immune to wall clock jumps
    QTimer m_ticker;
    QTimer m_alertTimeout;

    QList<qint64> m_presetMs { 60000, 300000, 600000, 1800000 };
};

#endif // TIMERMODEL_H
