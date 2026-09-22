#ifndef CALCULATORVIEWMODEL_H
#define CALCULATORVIEWMODEL_H

#include <QObject>
#include <QString>
#include <QAbstractListModel>
#include "../Models/calculatormodel.h"

// CalculatorModel'in QML'e bakan ince yüzü. Hesap mantığı burada değil;
// bu sınıf yalnızca özellikleri açar ve komutları modele iletir.
class CalculatorViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString displayText    READ displayText    NOTIFY displayChanged)
    Q_PROPERTY(QString expressionText READ expressionText NOTIFY expressionChanged)
    Q_PROPERTY(bool hasError          READ hasError       NOTIFY errorChanged)

    Q_PROPERTY(QAbstractListModel* historyModel READ historyModel CONSTANT)
    Q_PROPERTY(int historyCount       READ historyCount   NOTIFY historyChanged)

    // Açı birimi: false = derece, true = radyan
    Q_PROPERTY(bool radians           READ radians        NOTIFY angleUnitChanged)

public:
    explicit CalculatorViewModel(QObject *parent = nullptr);

    QString displayText() const;
    QString expressionText() const;
    bool hasError() const;

    QAbstractListModel *historyModel() const;
    int historyCount() const;

    bool radians() const;

    // Girdi
    Q_INVOKABLE void digit(int value);
    Q_INVOKABLE void decimalPoint();
    Q_INVOKABLE void op(const QString &symbol);      // "+" "-" "*" "/" "^"
    Q_INVOKABLE void unary(const QString &fn);       // "sqrt" "sin" "ln" ...
    Q_INVOKABLE void constant(const QString &name);  // "pi" "e"
    Q_INVOKABLE void equals();
    Q_INVOKABLE void percent();
    Q_INVOKABLE void toggleSign();
    Q_INVOKABLE void backspace();
    Q_INVOKABLE void clearEntry();
    Q_INVOKABLE void clearAll();

    // Geçmiş
    Q_INVOKABLE void clearHistory();
    Q_INVOKABLE void recall(int index);

    // Ayar
    Q_INVOKABLE void setRadians(bool enabled);

signals:
    void displayChanged();
    void expressionChanged();
    void errorChanged();
    void historyChanged();
    void angleUnitChanged();

private:
    CalculatorModel *m_model;
};

#endif // CALCULATORVIEWMODEL_H
