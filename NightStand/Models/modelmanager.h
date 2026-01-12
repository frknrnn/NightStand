#ifndef MODELMANAGER_H
#define MODELMANAGER_H

#include <QObject>
#include "../Models/datetimemodel.h"
#include "../Models/todomodel.h"
#include "../Models/alarmmodel.h"

class ModelManager : public QObject
{
    Q_OBJECT
public:
    static ModelManager *instance();
    DateTimeModel* GetDateTimeModel();
    TodoModel* GetTodoModel();
    AlarmModel* GetAlarmModel();
    void init();

private:
    explicit ModelManager(QObject *parent = nullptr);
    ~ModelManager();
    static ModelManager* m_instance;
    Q_DISABLE_COPY(ModelManager)

    DateTimeModel *m_dateTimeModel;
    TodoModel *m_todoModel;
    AlarmModel *m_alarmModel;

signals:
};

#endif // MODELMANAGER_H
