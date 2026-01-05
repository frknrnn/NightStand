#include "todomodel.h"

TodoModel::TodoModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_nextId(1)
{
}

int TodoModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_todos.count();
}

QVariant TodoModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_todos.count())
        return QVariant();

    const TodoItem &item = m_todos.at(index.row());

    switch (role) {
    case IdRole:
        return item.id;
    case TitleRole:
        return item.title;
    case DescriptionRole:
        return item.description;
    case CompletedRole:
        return item.completed;
    case CreatedAtRole:
        return item.createdAt;
    case DueDateRole:
        return item.dueDate;
    default:
        return QVariant();
    }
}

bool TodoModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_todos.count())
        return false;

    TodoItem &item = m_todos[index.row()];

    switch (role) {
    case TitleRole:
        item.title = value.toString();
        break;
    case DescriptionRole:
        item.description = value.toString();
        break;
    case CompletedRole:
        item.completed = value.toBool();
        emit completedCountChanged();
        break;
    default:
        return false;
    }

    emit dataChanged(index, index, {role});
    return true;
}

Qt::ItemFlags TodoModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;
    return Qt::ItemIsEditable | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> TodoModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "todoId";
    roles[TitleRole] = "title";
    roles[DescriptionRole] = "description";
    roles[CompletedRole] = "completed";
    roles[CreatedAtRole] = "createdAt";
    roles[DueDateRole] = "dueDate";
    return roles;
}

void TodoModel::addTodo(const QString &title, const QString &description)
{
    if (title.trimmed().isEmpty())
        return;

    TodoItem item;
    item.id = m_nextId++;
    item.title = title.trimmed();
    item.description = description.trimmed();
    item.completed = false;
    item.createdAt = QDateTime::currentDateTime();

    beginInsertRows(QModelIndex(), m_todos.count(), m_todos.count());
    m_todos.append(item);
    endInsertRows();

    emit todoCountChanged();
}

void TodoModel::removeTodo(int id)
{
    int index = findTodoIndex(id);
    if (index < 0)
        return;

    bool wasCompleted = m_todos.at(index).completed;

    beginRemoveRows(QModelIndex(), index, index);
    m_todos.removeAt(index);
    endRemoveRows();

    emit todoCountChanged();
    if (wasCompleted)
        emit completedCountChanged();
}

void TodoModel::toggleCompleted(int id)
{
    int index = findTodoIndex(id);
    if (index < 0)
        return;

    m_todos[index].completed = !m_todos[index].completed;

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {CompletedRole});
    emit completedCountChanged();
}

void TodoModel::updateTodo(int id, const QString &title, const QString &description)
{
    int index = findTodoIndex(id);
    if (index < 0)
        return;

    m_todos[index].title = title.trimmed();
    m_todos[index].description = description.trimmed();

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {TitleRole, DescriptionRole});
}

void TodoModel::clearCompleted()
{
    for (int i = m_todos.count() - 1; i >= 0; --i) {
        if (m_todos.at(i).completed) {
            beginRemoveRows(QModelIndex(), i, i);
            m_todos.removeAt(i);
            endRemoveRows();
        }
    }
    emit todoCountChanged();
    emit completedCountChanged();
}

QList<TodoItem> TodoModel::todos() const
{
    return m_todos;
}

int TodoModel::todoCount() const
{
    return m_todos.count();
}

int TodoModel::completedCount() const
{
    int count = 0;
    for (const TodoItem &item : m_todos) {
        if (item.completed)
            ++count;
    }
    return count;
}

int TodoModel::findTodoIndex(int id) const
{
    for (int i = 0; i < m_todos.count(); ++i) {
        if (m_todos.at(i).id == id)
            return i;
    }
    return -1;
}
