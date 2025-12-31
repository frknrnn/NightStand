#ifndef APPVIEWMODEL_H
#define APPVIEWMODEL_H

#include <QObject>

class AppViewModel : public QObject
{
    Q_OBJECT
public:
    explicit AppViewModel(QObject *parent = nullptr);

signals:
};

#endif // APPVIEWMODEL_H
