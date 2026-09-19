import QtQuick
import QtMultimedia

// The ONLY file that imports QtMultimedia. It is reached through a Loader so
// that a target without the module (or without a working audio device) falls
// back to the visual alert instead of taking the whole window down.
SoundEffect {
    id: fx

    source: "qrc:/NightStand/Assets/sounds/timer_alert.wav"
    loops: SoundEffect.Infinite
    volume: 0.85

    Component.onCompleted: play()
    Component.onDestruction: stop()

    onStatusChanged: {
        if (status === SoundEffect.Error)
            console.warn("TimerAlertSound: audio unavailable, visual alert only")
    }
}
