#ifndef MODELMANAGER_H
#define MODELMANAGER_H

#include <QObject>
#include "../Models/datetimemodel.h"
#include "../Models/todomodel.h"

class ModelManager : public QObject
{
    Q_OBJECT
public:
    static ModelManager *instance();
    DateTimeModel* GetDateTimeModel();
    TodoModel* GetTodoModel();
    void init();

private:
    explicit ModelManager(QObject *parent = nullptr);
    ~ModelManager();
    static ModelManager* m_instance;
    Q_DISABLE_COPY(ModelManager)

    DateTimeModel *m_dateTimeModel;
    TodoModel *m_todoModel;

signals:
};

#endif // MODELMANAGER_H
