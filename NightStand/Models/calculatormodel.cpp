#include "calculatormodel.h"

#include <algorithm>
#include <cmath>

namespace {

// M_PI her derleyicide <cmath> ile gelmiyor (MSVC _USE_MATH_DEFINES ister).
constexpr double kPi = 3.14159265358979323846;
constexpr double kE  = 2.71828182845904523536;

// Binlik ayracı olarak ince boşluk (U+2009). Ondalık ayracımız nokta olduğu
// için virgül ya da nokta kullanmak Türkçe/İngilizce okuma alışkanlıkları
// arasında sıkışıp kalıyordu; ince boşluk her iki okumada da doğru.
const QChar kGroupSeparator(0x2009);

// Derece<->radyan çevrimi 0.49999999999999994 gibi artıklar üretiyor. Sonuç
// 12 anlamlı basamak içinde bir tam sayıya yapışıyorsa oraya oturt - ekranda
// değil saklanan değerde, ki sonraki işlemler de temiz olsun.
double snap(double value)
{
    if (!std::isfinite(value) || value == 0.0)
        return value;
    const double rounded = std::round(value);
    if (std::fabs(value - rounded) < 1e-12 * std::max(1.0, std::fabs(value)))
        return rounded;
    return value;
}

int digitCount(const QString &text)
{
    int count = 0;
    for (const QChar &c : text) {
        if (c.isDigit())
            ++count;
    }
    return count;
}

} // namespace

CalculatorModel::CalculatorModel(QObject *parent)
    : QObject{parent}
    , m_history(new CalculatorHistoryModel(this))
{
    connect(m_history, &CalculatorHistoryModel::countChanged,
            this, &CalculatorModel::historyChanged);
}

// ---------------------------------------------------------------- yardımcılar

double CalculatorModel::currentValue() const
{
    return m_typing ? m_entry.toDouble() : m_current;
}

void CalculatorModel::setCurrent(double value)
{
    if (!std::isfinite(value)) {
        setError();
        return;
    }
    m_current = value;
    m_entry.clear();
    m_typing = false;
}

void CalculatorModel::setError()
{
    if (m_error)
        return;
    m_error = true;
    m_typing = false;
    m_entry.clear();
    m_pendingOp.clear();
    m_lastOp.clear();
    emit errorChanged();
    emit displayChanged();
}

// Hata ekrandayken bir rakama basmak yeni bir hesaba başlamak demektir.
void CalculatorModel::clearErrorOnInput()
{
    if (m_error)
        clearAll();
}

QString CalculatorModel::operatorSymbol(const QString &op)
{
    if (op == QLatin1String("+")) return QStringLiteral("+");
    if (op == QLatin1String("-")) return QStringLiteral("−");   // minus
    if (op == QLatin1String("*")) return QStringLiteral("×");   // times
    if (op == QLatin1String("/")) return QStringLiteral("÷");   // divide
    if (op == QLatin1String("^")) return QStringLiteral("^");
    return op;
}

QString CalculatorModel::groupInteger(const QString &digits)
{
    if (digits.size() <= 3)
        return digits;

    QString out;
    out.reserve(digits.size() + digits.size() / 3);
    int sinceBreak = 0;
    for (int i = digits.size() - 1; i >= 0; --i) {
        if (sinceBreak == 3) {
            out.prepend(kGroupSeparator);
            sinceBreak = 0;
        }
        out.prepend(digits.at(i));
        ++sinceBreak;
    }
    return out;
}

// Yazım sürerken ham girdiyi bozmadan yalnız görüntüyü gruplar; sondaki
// nokta ("12.") korunur, yoksa ondalık basamak yazılamaz.
QString CalculatorModel::groupEntry(const QString &entry)
{
    QString sign;
    QString body = entry;
    if (body.startsWith(QLatin1Char('-'))) {
        sign = QStringLiteral("-");
        body.remove(0, 1);
    }

    const int dot = body.indexOf(QLatin1Char('.'));
    if (dot < 0)
        return sign + groupInteger(body);

    return sign + groupInteger(body.left(dot)) + body.mid(dot);
}

QString CalculatorModel::formatNumber(double value)
{
    if (!std::isfinite(value))
        //: Hata
        return tr("Error");
    if (value == 0.0)
        return QStringLiteral("0");

    const double magnitude = std::fabs(value);

    // Çok büyük / çok küçük: bilimsel gösterim, mantisin sonundaki sıfırlar atılır.
    if (magnitude >= 1e12 || magnitude < 1e-6) {
        QString text = QString::number(value, 'e', 6);
        const int e = text.indexOf(QLatin1Char('e'));
        if (e > 0) {
            QString mantissa = text.left(e);
            const QString exponent = text.mid(e);
            if (mantissa.contains(QLatin1Char('.'))) {
                while (mantissa.endsWith(QLatin1Char('0')))
                    mantissa.chop(1);
                if (mantissa.endsWith(QLatin1Char('.')))
                    mantissa.chop(1);
            }
            text = mantissa + exponent;
        }
        return text;
    }

    // 'g' bu aralıkta bile üsse kaçabiliyor (1e-5 -> "1e-05"), o yüzden
    // basamak sayısını kendimiz hesaplayıp 'f' kullanıyoruz.
    const int exponent = int(std::floor(std::log10(magnitude)));
    int decimals = kSignificantDigits - 1 - exponent;
    decimals = qBound(0, decimals, 15);

    QString text = QString::number(value, 'f', decimals);
    if (text.contains(QLatin1Char('.'))) {
        while (text.endsWith(QLatin1Char('0')))
            text.chop(1);
        if (text.endsWith(QLatin1Char('.')))
            text.chop(1);
    }

    // Yuvarlama "-0" üretebiliyor; ekranda eksili sıfır görünmesin
    if (text == QLatin1String("-0"))
        return QStringLiteral("0");

    return groupEntry(text);
}

// ---------------------------------------------------------------- durum

QString CalculatorModel::displayText() const
{
    if (m_error)
        //: Hata
        return tr("Error");
    if (m_typing)
        return groupEntry(m_entry);
    return formatNumber(m_current);
}

QString CalculatorModel::expressionText() const
{
    return m_error ? QString() : m_expression;
}

void CalculatorModel::setAngleUnit(AngleUnit unit)
{
    if (m_angleUnit == unit)
        return;
    m_angleUnit = unit;
    emit angleUnitChanged();
}

// ---------------------------------------------------------------- girdi

void CalculatorModel::inputDigit(int digit)
{
    if (digit < 0 || digit > 9)
        return;

    clearErrorOnInput();

    if (!m_typing) {
        m_entry = QStringLiteral("0");
        m_typing = true;
    }

    const QString d = QString::number(digit);

    if (m_entry == QLatin1String("0"))
        m_entry = d;
    else if (m_entry == QLatin1String("-0"))
        m_entry = QStringLiteral("-") + d;
    else if (digitCount(m_entry) < kMaxEntryDigits)
        m_entry += d;

    emit displayChanged();
}

void CalculatorModel::inputDecimalPoint()
{
    clearErrorOnInput();

    if (!m_typing) {
        m_entry = QStringLiteral("0");
        m_typing = true;
    }
    if (!m_entry.contains(QLatin1Char('.')))
        m_entry += QLatin1Char('.');

    emit displayChanged();
}

void CalculatorModel::inputConstant(const QString &name)
{
    clearErrorOnInput();

    if (name == QLatin1String("pi"))
        setCurrent(kPi);
    else if (name == QLatin1String("e"))
        setCurrent(kE);
    else
        return;

    emit displayChanged();
}

void CalculatorModel::toggleSign()
{
    if (m_error)
        return;

    if (m_typing) {
        if (m_entry.startsWith(QLatin1Char('-')))
            m_entry.remove(0, 1);
        else if (m_entry != QLatin1String("0"))
            m_entry.prepend(QLatin1Char('-'));
    } else if (m_current != 0.0) {
        m_current = -m_current;
    }

    emit displayChanged();
}

void CalculatorModel::backspace()
{
    if (m_error) {
        clearAll();
        return;
    }
    if (!m_typing)
        return;

    m_entry.chop(1);
    if (m_entry.isEmpty() || m_entry == QLatin1String("-"))
        m_entry = QStringLiteral("0");

    emit displayChanged();
}

void CalculatorModel::clearEntry()
{
    if (m_error) {
        clearAll();
        return;
    }
    m_entry = QStringLiteral("0");
    m_typing = true;
    emit displayChanged();
}

void CalculatorModel::clearAll()
{
    const bool wasError = m_error;

    m_entry.clear();
    m_typing = false;
    m_current = 0.0;
    m_accumulator = 0.0;
    m_pendingOp.clear();
    m_lastOperand = 0.0;
    m_lastOp.clear();
    m_expression.clear();
    m_error = false;

    if (wasError)
        emit errorChanged();
    emit displayChanged();
    emit expressionChanged();
}

// ---------------------------------------------------------------- işlemler

double CalculatorModel::applyBinary(double lhs, double rhs, const QString &op)
{
    double result = 0.0;

    if (op == QLatin1String("+")) {
        result = lhs + rhs;
    } else if (op == QLatin1String("-")) {
        result = lhs - rhs;
    } else if (op == QLatin1String("*")) {
        result = lhs * rhs;
    } else if (op == QLatin1String("/")) {
        if (rhs == 0.0) {
            setError();
            return 0.0;
        }
        result = lhs / rhs;
    } else if (op == QLatin1String("^")) {
        result = std::pow(lhs, rhs);
    } else {
        return lhs;
    }

    if (!std::isfinite(result)) {
        setError();
        return 0.0;
    }
    return result;
}

void CalculatorModel::inputOperator(const QString &op)
{
    if (m_error)
        return;

    if (!m_pendingOp.isEmpty() && m_typing) {
        // Zincirleme: yeni operatöre geçmeden önce bekleyeni kapat
        const double result = applyBinary(m_accumulator, currentValue(), m_pendingOp);
        if (m_error)
            return;
        m_accumulator = result;
        setCurrent(result);
    } else {
        // Bekleyen yok ya da sayı yazılmadı: operatörü değiştirmiş oluyoruz
        m_accumulator = currentValue();
        m_entry.clear();
        m_typing = false;
        m_current = m_accumulator;
    }

    m_pendingOp = op;
    m_lastOp.clear();   // yeni işlem: tekrarlı "=" zinciri sıfırlanır

    m_expression = formatNumber(m_accumulator) + QLatin1Char(' ') + operatorSymbol(op);

    emit displayChanged();
    emit expressionChanged();
}

void CalculatorModel::equals()
{
    if (m_error)
        return;

    QString op;
    double lhs = 0.0;
    double rhs = 0.0;

    if (!m_pendingOp.isEmpty()) {
        op  = m_pendingOp;
        lhs = m_accumulator;
        rhs = currentValue();
    } else if (!m_lastOp.isEmpty()) {
        // Ardışık "=": son operatör ve son sağ terim tekrarlanır
        op  = m_lastOp;
        lhs = currentValue();
        rhs = m_lastOperand;
    } else {
        return;
    }

    const QString expression = formatNumber(lhs) + QLatin1Char(' ')
                             + operatorSymbol(op) + QLatin1Char(' ')
                             + formatNumber(rhs);

    const double result = applyBinary(lhs, rhs, op);
    if (m_error)
        return;

    m_lastOp = op;
    m_lastOperand = rhs;
    m_pendingOp.clear();
    m_accumulator = result;
    setCurrent(result);

    m_expression = expression + QStringLiteral(" =");
    pushHistory(expression, result);

    emit displayChanged();
    emit expressionChanged();
}

void CalculatorModel::percent()
{
    if (m_error)
        return;

    const double value = currentValue();

    // "200 + 10 %" -> 200'un %10'u; "50 x 10 %" -> sadece 0.10
    const bool additive = (m_pendingOp == QLatin1String("+")
                        || m_pendingOp == QLatin1String("-"));
    const double result = additive ? m_accumulator * value / 100.0
                                   : value / 100.0;

    setCurrent(result);
    emit displayChanged();
}

void CalculatorModel::applyUnary(const QString &fn)
{
    if (m_error)
        return;

    const double value = currentValue();
    const QString valueText = formatNumber(value);
    const double asRadians = (m_angleUnit == Degrees) ? value * kPi / 180.0 : value;

    double result = 0.0;
    QString expression;

    if (fn == QLatin1String("sqrt")) {
        if (value < 0.0) { setError(); return; }
        result = std::sqrt(value);
        expression = QStringLiteral("√(") + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("sqr")) {
        result = value * value;
        expression = valueText + QStringLiteral("²");

    } else if (fn == QLatin1String("inv")) {
        if (value == 0.0) { setError(); return; }
        result = 1.0 / value;
        expression = QStringLiteral("1/(") + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("sin") || fn == QLatin1String("cos")
            || fn == QLatin1String("tan")) {
        // tan(90) sonsuz; double bunu 1.6e16 diye "basarili" dondurdugu icin
        // derece modunda elle yakaliyoruz
        if (fn == QLatin1String("tan") && m_angleUnit == Degrees
            && std::fmod(std::fabs(value), 180.0) == 90.0) { setError(); return; }
        result = (fn == QLatin1String("sin")) ? std::sin(asRadians)
               : (fn == QLatin1String("cos")) ? std::cos(asRadians)
                                              : std::tan(asRadians);
        result = snap(result);
        expression = fn + QLatin1Char('(') + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("asin") || fn == QLatin1String("acos")
            || fn == QLatin1String("atan")) {
        if (fn != QLatin1String("atan") && (value < -1.0 || value > 1.0)) { setError(); return; }
        double angle = (fn == QLatin1String("asin")) ? std::asin(value)
                     : (fn == QLatin1String("acos")) ? std::acos(value)
                                                     : std::atan(value);
        if (m_angleUnit == Degrees)
            angle = angle * 180.0 / kPi;
        result = snap(angle);
        expression = fn + QLatin1Char('(') + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("ln")) {
        if (value <= 0.0) { setError(); return; }
        result = snap(std::log(value));
        expression = QStringLiteral("ln(") + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("log")) {
        if (value <= 0.0) { setError(); return; }
        result = snap(std::log10(value));
        expression = QStringLiteral("log(") + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("exp")) {
        result = std::exp(value);
        expression = QStringLiteral("e^(") + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("tenx")) {
        result = std::pow(10.0, value);
        expression = QStringLiteral("10^(") + valueText + QLatin1Char(')');

    } else if (fn == QLatin1String("fact")) {
        if (value < 0.0 || value > 170.0 || value != std::floor(value)) { setError(); return; }
        double factorial = 1.0;
        for (int i = 2; i <= int(value); ++i)
            factorial *= i;
        result = factorial;
        expression = valueText + QLatin1Char('!');

    } else if (fn == QLatin1String("abs")) {
        result = std::fabs(value);
        expression = QStringLiteral("|") + valueText + QLatin1Char('|');

    } else {
        return;
    }

    if (!std::isfinite(result)) {
        setError();
        return;
    }

    setCurrent(result);
    m_expression = expression + QStringLiteral(" =");
    pushHistory(expression, result);

    emit displayChanged();
    emit expressionChanged();
}

// ---------------------------------------------------------------- geçmiş

void CalculatorModel::pushHistory(const QString &expression, double result)
{
    // countChanged -> historyChanged bağlantısı yapıcıda kuruldu
    m_history->prepend(expression, formatNumber(result), result);
}

void CalculatorModel::clearHistory()
{
    m_history->clear();
}

void CalculatorModel::recallHistory(int index)
{
    if (!m_history->hasRow(index))
        return;

    const double value = m_history->valueAt(index);

    if (m_error) {
        m_error = false;
        emit errorChanged();
    }

    setCurrent(value);
    m_accumulator = value;
    m_pendingOp.clear();
    m_lastOp.clear();
    // İkincil satır sonucun nereden geldiğini göstermeye devam etsin
    m_expression = m_history->expressionAt(index);

    emit displayChanged();
    emit expressionChanged();
}
