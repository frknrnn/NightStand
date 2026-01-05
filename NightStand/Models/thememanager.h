#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QColor>
#include <QVariantMap>
#include <QJsonObject>
#include <QJsonArray>

struct ThemeColors {
    QColor baseColor;
    QColor cardPanelColor;
    QColor innerCardColor;
    QColor roundButtonColor;
    QColor textColor;
    QColor subtextColor;
    QColor headerColor;
    QColor buttonProgress;
    QColor menuTextColor;
    QColor white;
    QColor black;
    QColor transparent;
    QColor red;
};

class ThemeManager : public QObject
{
    Q_OBJECT
    
    // Theme name property
    Q_PROPERTY(QString currentTheme READ currentTheme WRITE setCurrentTheme NOTIFY currentThemeChanged)
    Q_PROPERTY(QStringList availableThemes READ availableThemes NOTIFY availableThemesChanged)
    Q_PROPERTY(bool isDarkTheme READ isDarkTheme NOTIFY currentThemeChanged)
    
    // Color properties for QML binding
    Q_PROPERTY(QColor baseColor READ baseColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor cardPanelColor READ cardPanelColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor innerCardColor READ innerCardColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor roundButtonColor READ roundButtonColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor textColor READ textColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor subtextColor READ subtextColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor headerColor READ headerColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor buttonProgress READ buttonProgress NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor menuTextColor READ menuTextColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor white READ white CONSTANT)
    Q_PROPERTY(QColor black READ black CONSTANT)
    Q_PROPERTY(QColor transparent READ transparent CONSTANT)
    Q_PROPERTY(QColor red READ red NOTIFY themeColorsChanged)

public:
    static ThemeManager* instance();
    
    // Theme management
    QString currentTheme() const;
    void setCurrentTheme(const QString &themeName);
    QStringList availableThemes() const;
    bool isDarkTheme() const;
    
    // Color getters
    QColor baseColor() const;
    QColor cardPanelColor() const;
    QColor innerCardColor() const;
    QColor roundButtonColor() const;
    QColor textColor() const;
    QColor subtextColor() const;
    QColor headerColor() const;
    QColor buttonProgress() const;
    QColor menuTextColor() const;
    QColor white() const;
    QColor black() const;
    QColor transparent() const;
    QColor red() const;
    
    // Theme operations
    Q_INVOKABLE void addTheme(const QString &themeName, const QVariantMap &colors);
    Q_INVOKABLE QVariantMap getThemeColors(const QString &themeName) const;

signals:
    void currentThemeChanged();
    void themeColorsChanged();
    void availableThemesChanged();

private:
    explicit ThemeManager(QObject *parent = nullptr);
    ~ThemeManager();
    static ThemeManager* m_instance;
    Q_DISABLE_COPY(ThemeManager)
    
    void initDefaultThemes();
    void loadThemeColors();
    
    QString m_currentTheme;
    QMap<QString, ThemeColors> m_themes;
    ThemeColors m_currentColors;
};

#endif // THEMEMANAGER_H
