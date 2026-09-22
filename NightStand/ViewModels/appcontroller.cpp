#include "appcontroller.h"

AppController::AppController(QObject *parent)
    : QObject{parent}
    , m_nightMode(false)
{
    dateTimeViewModel = new DateTimeViewModel();
    todoViewModel = new TodoViewModel();
    alarmViewModel = new AlarmViewModel();
    timerViewModel = new TimerViewModel();
    calculatorViewModel = new CalculatorViewModel();
}

void AppController::setNightMode(bool enabled)
{
    if (m_nightMode != enabled) {
        m_nightMode = enabled;
        emit nightModeChanged();
    }
}

void AppController::toggleNightMode()
{
    setNightMode(!m_nightMode);
}

void AppController::setFlashMode(bool enabled)
{
    if (m_flashMode != enabled) {
        m_flashMode = enabled;
        emit flashModeChanged();
    }
}

void AppController::toggleFlashMode()
{
    setFlashMode(!m_flashMode);
}

void AppController::setReadingMode(bool enabled)
{
    if (m_readingMode != enabled) {
        m_readingMode = enabled;
        emit readingModeChanged();
    }
}

void AppController::toggleReadingMode()
{
    setReadingMode(!m_readingMode);
}

void AppController::setGalleryMode(bool enabled)
{
    if (m_galleryMode != enabled) {
        m_galleryMode = enabled;
        emit galleryModeChanged();
    }
}

void AppController::toggleGalleryMode()
{
    setGalleryMode(!m_galleryMode);
}

void AppController::setAmbianceMode(bool enabled)
{
    if (m_ambianceMode != enabled) {
        m_ambianceMode = enabled;
        emit ambianceModeChanged();
    }
}

void AppController::toggleAmbianceMode()
{
    setAmbianceMode(!m_ambianceMode);
}

void AppController::setBreathingMode(bool enabled)
{
    if (m_breathingMode != enabled) {
        m_breathingMode = enabled;
        emit breathingModeChanged();
    }
}

void AppController::toggleBreathingMode()
{
    setBreathingMode(!m_breathingMode);
}
