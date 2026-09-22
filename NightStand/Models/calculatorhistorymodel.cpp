#include "calculatorhistorymodel.h"

CalculatorHistoryModel::CalculatorHistoryModel(QObject *parent)
    : QAbstractListModel{parent}
{
}

int CalculatorHistoryModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return int(m_entries.size());
}

QVariant CalculatorHistoryModel::data(const QModelIndex &index, int role) const
{
    if (!hasRow(index.row()))
        return QVariant();

    const Entry &entry = m_entries.at(index.row());

    switch (role) {
    case ExpressionRole: return entry.expression;
    case ResultRole:     return entry.resultText;
    case ValueRole:      return entry.value;
    default:             return QVariant();
    }
}

QHash<int, QByteArray> CalculatorHistoryModel::roleNames() const
{
    return {
        { ExpressionRole, QByteArrayLiteral("expression") },
        { ResultRole,     QByteArrayLiteral("result") },
        { ValueRole,      QByteArrayLiteral("value") }
    };
}

void CalculatorHistoryModel::prepend(const QString &expression,
                                     const QString &resultText,
                                     double value)
{
    beginInsertRows(QModelIndex(), 0, 0);
    m_entries.prepend(Entry{ expression, resultText, value });
    endInsertRows();

    // Tavanı aşan en eski kayıtları at
    while (m_entries.size() > kMaxHistory) {
        const int last = int(m_entries.size()) - 1;
        beginRemoveRows(QModelIndex(), last, last);
        m_entries.removeLast();
        endRemoveRows();
    }

    emit countChanged();
}

void CalculatorHistoryModel::clear()
{
    if (m_entries.isEmpty())
        return;

    beginResetModel();
    m_entries.clear();
    endResetModel();

    emit countChanged();
}

bool CalculatorHistoryModel::hasRow(int row) const
{
    return row >= 0 && row < int(m_entries.size());
}

double CalculatorHistoryModel::valueAt(int row) const
{
    return hasRow(row) ? m_entries.at(row).value : 0.0;
}

QString CalculatorHistoryModel::expressionAt(int row) const
{
    return hasRow(row) ? m_entries.at(row).expression : QString();
}
