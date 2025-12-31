#ifndef MODELMANAGER_H
#define MODELMANAGER_H

#include <QObject>

class ModelManager : public QObject
{
    Q_OBJECT
public:
    explicit ModelManager(QObject *parent = nullptr);

signals:
};

#endif // MODELMANAGER_H
