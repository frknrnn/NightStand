#ifndef TODOVIEWMODEL_H
#define TODOVIEWMODEL_H

#include <QObject>
#include <QSortFilterProxyModel>
#include "../Models/todomodel.h"

class TodoViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QAbstractListModel* todoModel READ todoModel CONSTANT)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int completedCount READ completedCount NOTIFY completedCountChanged)
    Q_PROPERTY(int pendingCount READ pendingCount NOTIFY pendingCountChanged)
    Q_PROPERTY(QString filterMode READ filterMode WRITE setFilterMode NOTIFY filterModeChanged)

public:
    explicit TodoViewModel(QObject *parent = nullptr);

    QAbstractListModel* todoModel() const;

    int totalCount() const;
    int completedCount() const;
    int pendingCount() const;

    QString filterMode() const;
    void setFilterMode(const QString &mode);

    // QML invokable methods
    Q_INVOKABLE void addTodo(const QString &title, const QString &description = QString());
    Q_INVOKABLE void removeTodo(int id);
    Q_INVOKABLE void toggleCompleted(int id);
    Q_INVOKABLE void updateTodo(int id, const QString &title, const QString &description);
    Q_INVOKABLE void clearCompleted();
    
    // Get pending todo at index (for preview card)
    Q_INVOKABLE QString getPendingTodoTitle(int index) const;
    Q_INVOKABLE int getPendingTodoCount() const;

signals:
    void totalCountChanged();
    void completedCountChanged();
    void pendingCountChanged();
    void filterModeChanged();

private slots:
    void onTodoCountChanged();
    void onCompletedCountChanged();

private:
    TodoModel *m_model;
    QString m_filterMode;
};

#endif // TODOVIEWMODEL_H
