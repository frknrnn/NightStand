#include "calculatorviewmodel.h"

CalculatorViewModel::CalculatorViewModel(QObject *parent)
    : QObject{parent}
    , m_model(new CalculatorModel(this))
{
    connect(m_model, &CalculatorModel::displayChanged,
            this, &CalculatorViewModel::displayChanged);
    connect(m_model, &CalculatorModel::expressionChanged,
            this, &CalculatorViewModel::expressionChanged);
    connect(m_model, &CalculatorModel::errorChanged,
            this, &CalculatorViewModel::errorChanged);
    connect(m_model, &CalculatorModel::historyChanged,
            this, &CalculatorViewModel::historyChanged);
    connect(m_model, &CalculatorModel::angleUnitChanged,
            this, &CalculatorViewModel::angleUnitChanged);
}

// ---------------------------------------------------------------- okuma

QString CalculatorViewModel::displayText() const    { return m_model->displayText(); }
QString CalculatorViewModel::expressionText() const { return m_model->expressionText(); }
bool CalculatorViewModel::hasError() const          { return m_model->hasError(); }
int CalculatorViewModel::historyCount() const       { return m_model->historyCount(); }

QAbstractListModel *CalculatorViewModel::historyModel() const
{
    return m_model->historyModel();
}

bool CalculatorViewModel::radians() const
{
    return m_model->angleUnit() == CalculatorModel::Radians;
}

// ---------------------------------------------------------------- komutlar

void CalculatorViewModel::digit(int value)                 { m_model->inputDigit(value); }
void CalculatorViewModel::decimalPoint()                   { m_model->inputDecimalPoint(); }
void CalculatorViewModel::op(const QString &symbol)        { m_model->inputOperator(symbol); }
void CalculatorViewModel::unary(const QString &fn)         { m_model->applyUnary(fn); }
void CalculatorViewModel::constant(const QString &name)    { m_model->inputConstant(name); }
void CalculatorViewModel::equals()                         { m_model->equals(); }
void CalculatorViewModel::percent()                        { m_model->percent(); }
void CalculatorViewModel::toggleSign()                     { m_model->toggleSign(); }
void CalculatorViewModel::backspace()                      { m_model->backspace(); }
void CalculatorViewModel::clearEntry()                     { m_model->clearEntry(); }
void CalculatorViewModel::clearAll()                       { m_model->clearAll(); }
void CalculatorViewModel::clearHistory()                   { m_model->clearHistory(); }
void CalculatorViewModel::recall(int index)                { m_model->recallHistory(index); }

void CalculatorViewModel::setRadians(bool enabled)
{
    m_model->setAngleUnit(enabled ? CalculatorModel::Radians
                                  : CalculatorModel::Degrees);
}
