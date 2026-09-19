#ifndef TIMERVIEWMODEL_H
#define TIMERVIEWMODEL_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include "../Models/timermodel.h"

class TimerViewModel : public QObject
{
    Q_OBJECT

    // State. Named timerState (not state) so it never collides with Item.state in QML.
    Q_PROPERTY(int timerState READ timerState NOTIFY stateChanged)
    Q_PROPERTY(bool idle READ idle NOTIFY stateChanged)
    Q_PROPERTY(bool running READ running NOTIFY stateChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY stateChanged)
    Q_PROPERTY(bool finished READ finished NOTIFY stateChanged)
    Q_PROPERTY(bool active READ active NOTIFY stateChanged)

    // High frequency (~20 Hz): only the ring should bind to this.
    Q_PROPERTY(qreal progress READ progress NOTIFY remainingMsChanged)

    // Low frequency (~1 Hz): the digits bind here.
    Q_PROPERTY(QString remainingText READ remainingText NOTIFY remainingSecondsChanged)
    Q_PROPERTY(bool showsHours READ showsHours NOTIFY remainingSecondsChanged)

    Q_PROPERTY(QString totalText READ totalText NOTIFY totalMsChanged)
    Q_PROPERTY(QString endsAtText READ endsAtText NOTIFY endsAtChanged)

    Q_PROPERTY(int selectedHours READ selectedHours NOTIFY selectedDurationChanged)
    Q_PROPERTY(int selectedMinutes READ selectedMinutes NOTIFY selectedDurationChanged)
    Q_PROPERTY(int selectedSeconds READ selectedSeconds NOTIFY selectedDurationChanged)
    Q_PROPERTY(bool canStart READ canStart NOTIFY selectedDurationChanged)

    Q_PROPERTY(QVariantList presets READ presets NOTIFY presetsChanged)
    Q_PROPERTY(bool alerting READ alerting NOTIFY alertingChanged)

public:
    explicit TimerViewModel(QObject *parent = nullptr);

    int timerState() const;
    bool idle() const;
    bool running() const;
    bool paused() const;
    bool finished() const;
    bool active() const;

    qreal progress() const;
    QString remainingText() const;
    bool showsHours() const;
    QString totalText() const;
    QString endsAtText() const;

    int selectedHours() const;
    int selectedMinutes() const;
    int selectedSeconds() const;
    bool canStart() const;

    QVariantList presets() const;
    bool alerting() const;

    Q_INVOKABLE void setSelectedDuration(int hours, int minutes, int seconds);
    Q_INVOKABLE void applyPreset(int index);
    Q_INVOKABLE void start();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void resume();
    Q_INVOKABLE void toggleStartPause();
    Q_INVOKABLE void cancel();
    Q_INVOKABLE void addOneMinute();
    Q_INVOKABLE void dismissAlert();
    Q_INVOKABLE QString formatMs(qint64 ms) const;

signals:
    void stateChanged();
    void remainingMsChanged();
    void remainingSecondsChanged();
    void totalMsChanged();
    void selectedDurationChanged();
    void presetsChanged();
    void alertingChanged();
    void endsAtChanged();

private:
    TimerModel *m_model;
};

#endif // TIMERVIEWMODEL_H
