#include "todoviewmodel.h"
#include "../Models/modelmanager.h"

TodoViewModel::TodoViewModel(QObject *parent)
    : QObject(parent)
    , m_filterMode("all")
{
    m_model = ModelManager::instance()->GetTodoModel();
    connect(m_model, &TodoModel::todoCountChanged, this, &TodoViewModel::onTodoCountChanged);
    connect(m_model, &TodoModel::completedCountChanged, this, &TodoViewModel::onCompletedCountChanged);
}

QAbstractListModel* TodoViewModel::todoModel() const
{
    return m_model;
}

int TodoViewModel::totalCount() const
{
    return m_model->todoCount();
}

int TodoViewModel::completedCount() const
{
    return m_model->completedCount();
}

int TodoViewModel::pendingCount() const
{
    return m_model->todoCount() - m_model->completedCount();
}

QString TodoViewModel::filterMode() const
{
    return m_filterMode;
}

void TodoViewModel::setFilterMode(const QString &mode)
{
    if (m_filterMode != mode) {
        m_filterMode = mode;
        emit filterModeChanged();
    }
}

void TodoViewModel::addTodo(const QString &title, const QString &description)
{
    m_model->addTodo(title, description);
}

void TodoViewModel::removeTodo(int id)
{
    m_model->removeTodo(id);
}

void TodoViewModel::toggleCompleted(int id)
{
    m_model->toggleCompleted(id);
}

void TodoViewModel::updateTodo(int id, const QString &title, const QString &description)
{
    m_model->updateTodo(id, title, description);
}

void TodoViewModel::clearCompleted()
{
    m_model->clearCompleted();
}

void TodoViewModel::onTodoCountChanged()
{
    emit totalCountChanged();
    emit pendingCountChanged();
}

void TodoViewModel::onCompletedCountChanged()
{
    emit completedCountChanged();
    emit pendingCountChanged();
}
