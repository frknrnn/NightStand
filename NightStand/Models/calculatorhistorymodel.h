#ifndef CALCULATORHISTORYMODEL_H
#define CALCULATORHISTORYMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QString>

// İşlem geçmişi. Yalnızca başa ekleme ve topluca temizleme var - düzenleme
// ya da tek tek silme yok.
//
// Bu yine de QVariantList değil QAbstractListModel: ListView'in `add`
// geçişi gerçek bir satır ekleme sinyaline bağlı. Listeyi her hesapta
// yeniden kurup verseydik ListView bunu model sıfırlaması sayar ve yeni
// satır animasyonsuz belirirdi.
class CalculatorHistoryModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum HistoryRoles {
        ExpressionRole = Qt::UserRole + 1,   // "12 × 4"
        ResultRole,                          // biçimlenmiş sonuç metni
        ValueRole                            // geri yükleme için ham double
    };

    explicit CalculatorHistoryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void prepend(const QString &expression, const QString &resultText, double value);
    void clear();

    bool hasRow(int row) const;
    double valueAt(int row) const;
    QString expressionAt(int row) const;

signals:
    void countChanged();

private:
    struct Entry {
        QString expression;
        QString resultText;
        double value;
    };

    QList<Entry> m_entries;   // en yeni başta

    static constexpr int kMaxHistory = 50;
};

#endif // CALCULATORHISTORYMODEL_H
