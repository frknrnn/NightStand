#ifndef CALCULATORMODEL_H
#define CALCULATORMODEL_H

#include <QObject>
#include <QString>
#include "calculatorhistorymodel.h"

// Saf hesap motoru. QML'den habersiz, tek sorumluluğu klasik bir hesap
// makinesinin durum makinesi: yazılan sayı, bekleyen işlem, biriken sonuç.
//
// Parantez ya da operatör önceliği YOK - "2 + 3 × 4" soldan sağa 20 verir.
// Bu bilinçli: dokunmatik bir gece lambası hesap makinesinde beklenen davranış
// cep hesap makinesininki, bilimsel ifade ayrıştırıcısınınki değil.
class CalculatorModel : public QObject
{
    Q_OBJECT

public:
    enum AngleUnit {
        Degrees = 0,
        Radians = 1
    };
    Q_ENUM(AngleUnit)

    explicit CalculatorModel(QObject *parent = nullptr);

    // --- Girdi ---
    void inputDigit(int digit);                 // 0..9
    void inputDecimalPoint();
    void inputOperator(const QString &op);      // "+" "-" "*" "/" "^"
    void inputConstant(const QString &name);    // "pi" "e"
    void applyUnary(const QString &fn);         // aşağıdaki listeye bak
    void equals();
    void percent();
    void toggleSign();
    void backspace();
    void clearEntry();                          // C  - yalnız girilen sayı
    void clearAll();                            // AC - her şey

    // --- Durum ---
    QString displayText() const;
    QString expressionText() const;
    bool hasError() const { return m_error; }

    CalculatorHistoryModel *historyModel() const { return m_history; }
    int historyCount() const { return m_history->rowCount(); }
    void clearHistory();
    void recallHistory(int index);

    AngleUnit angleUnit() const { return m_angleUnit; }
    void setAngleUnit(AngleUnit unit);

signals:
    void displayChanged();
    void expressionChanged();
    void historyChanged();
    void errorChanged();
    void angleUnitChanged();

private:
    // Ekranda duran sayı: yazım sürüyorsa m_entry, değilse m_current.
    double currentValue() const;

    // İki sayıyı birleştirir; sonuç sonlu değilse hata kurar ve 0 döner.
    double applyBinary(double lhs, double rhs, const QString &op);

    void setError();
    void clearErrorOnInput();
    void pushHistory(const QString &expression, double result);
    void setCurrent(double value);

    static QString formatNumber(double value);
    static QString groupInteger(const QString &digits);
    static QString groupEntry(const QString &entry);
    static QString operatorSymbol(const QString &op);

    QString   m_entry;                  // yazılmakta olan ham rakamlar ("12.5")
    bool      m_typing = false;         // m_entry canlı mı
    double    m_current = 0.0;          // yazım yokken ekrandaki değer
    double    m_accumulator = 0.0;      // bekleyen işlemin sol tarafı
    QString   m_pendingOp;              // "" = bekleyen işlem yok
    double    m_lastOperand = 0.0;      // tekrarlanan "=" için
    QString   m_lastOp;
    QString   m_expression;             // ikincil satır
    bool      m_error = false;
    AngleUnit m_angleUnit = Degrees;

    CalculatorHistoryModel *m_history;

    static constexpr int kSignificantDigits = 12;
    static constexpr int kMaxEntryDigits = 16;
};

#endif // CALCULATORMODEL_H
