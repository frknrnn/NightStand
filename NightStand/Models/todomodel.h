#ifndef TODOMODEL_H
#define TODOMODEL_H

#include <QAbstractListModel>
#include <QDateTime>

struct TodoItem {
    int id;
    QString title;
    QString description;
    bool completed;
    QDateTime createdAt;
    QDateTime dueDate;
};

class TodoModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum TodoRoles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        DescriptionRole,
        CompletedRole,
        CreatedAtRole,
        DueDateRole
    };

    explicit TodoModel(QObject *parent = nullptr);

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Todo operations
    Q_INVOKABLE void addTodo(const QString &title, const QString &description = QString());
    Q_INVOKABLE void removeTodo(int id);
    Q_INVOKABLE void toggleCompleted(int id);
    Q_INVOKABLE void updateTodo(int id, const QString &title, const QString &description);
    Q_INVOKABLE void clearCompleted();

    // Getters
    QList<TodoItem> todos() const;
    int todoCount() const;
    int completedCount() const;

signals:
    void todoCountChanged();
    void completedCountChanged();

private:
    QList<TodoItem> m_todos;
    int m_nextId;

    int findTodoIndex(int id) const;
};

#endif // TODOMODEL_H
