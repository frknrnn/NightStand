#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include "../ViewModels/datetimeviewmodel.h"
#include "../ViewModels/todoviewmodel.h"
#include "../ViewModels/alarmviewmodel.h"

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool nightMode READ nightMode WRITE setNightMode NOTIFY nightModeChanged)
    Q_PROPERTY(bool flashMode READ flashMode WRITE setFlashMode NOTIFY flashModeChanged)
    Q_PROPERTY(bool readingMode READ readingMode WRITE setReadingMode NOTIFY readingModeChanged)
    Q_PROPERTY(bool galleryMode READ galleryMode WRITE setGalleryMode NOTIFY galleryModeChanged)

public:
    explicit AppController(QObject *parent = nullptr);
    DateTimeViewModel *getDateTimeViewModel() { return dateTimeViewModel; }
    TodoViewModel *getTodoViewModel() { return todoViewModel; }
    AlarmViewModel *getAlarmViewModel() { return alarmViewModel; }

    bool nightMode() const { return m_nightMode; }
    void setNightMode(bool enabled);
    Q_INVOKABLE void toggleNightMode();

    bool flashMode() const { return m_flashMode; }
    void setFlashMode(bool enabled);
    Q_INVOKABLE void toggleFlashMode();

    bool readingMode() const { return m_readingMode; }
    void setReadingMode(bool enabled);
    Q_INVOKABLE void toggleReadingMode();

    bool galleryMode() const { return m_galleryMode; }
    void setGalleryMode(bool enabled);
    Q_INVOKABLE void toggleGalleryMode();

private:
    DateTimeViewModel *dateTimeViewModel;
    TodoViewModel *todoViewModel;
    AlarmViewModel *alarmViewModel;
    bool m_nightMode = false;
    bool m_flashMode = false;
    bool m_readingMode = false;
    bool m_galleryMode = false;

signals:
    void nightModeChanged();
    void flashModeChanged();
    void readingModeChanged();
    void galleryModeChanged();
};

#endif // APPCONTROLLER_H
