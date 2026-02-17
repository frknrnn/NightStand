#include "thememanager.h"
#include <QDebug>

ThemeManager* ThemeManager::m_instance = nullptr;

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
    , m_currentTheme("black")
{
    initDefaultThemes();
    loadThemeColors();
}

ThemeManager::~ThemeManager()
{
}

ThemeManager* ThemeManager::instance()
{
    if (!m_instance) {
        m_instance = new ThemeManager();
    }
    return m_instance;
}

void ThemeManager::initDefaultThemes()
{
    // Black theme (AMOLED-friendly pure black with yellow accents)
    ThemeColors black;
    black.baseColor = QColor("#000000");
    black.cardPanelColor = QColor("#0a0a0a");
    black.innerCardColor = QColor("#141414");
    black.roundButtonColor = QColor("#1f1f1f");
    black.textColor = QColor("#FFD700");       // Altın sarısı (ana metin)
    black.subtextColor = QColor("#B8860B");    // Koyu altın (alt metin)
    black.headerColor = QColor("#FFC107");     // Amber sarı (başlık)
    black.buttonProgress = QColor("#FFD700");  // Altın sarısı (ilerleme)
    black.menuTextColor = QColor("#FFEB3B");   // Parlak sarı (menü)
    black.white = QColor("#FFFFFF");
    black.black = QColor("#000000");
    black.transparent = QColor(Qt::transparent);
    black.red = QColor("#ff3b30");
    m_themes["black"] = black;

    // Dark theme
    ThemeColors dark;
    dark.baseColor = QColor("#000000");
    dark.cardPanelColor = QColor("#1a2942");
    dark.innerCardColor = QColor("#223548");
    dark.roundButtonColor = QColor("#2a3f5f");
    dark.textColor = QColor("#FFFFFF");
    dark.subtextColor = QColor("#7a8fa8");
    dark.headerColor = QColor("#6366f1");
    dark.buttonProgress = QColor("#28C878");
    dark.menuTextColor = QColor("#eb8e3d");
    dark.white = QColor("#FFFFFF");
    dark.black = QColor("#000000");
    dark.transparent = QColor(Qt::transparent);
    dark.red = QColor("#fc0022");
    m_themes["dark"] = dark;
    
    // Light theme
    ThemeColors light;
    light.baseColor = QColor("#FFFFFF");
    light.cardPanelColor = QColor("#F5F5F5");
    light.innerCardColor = QColor("#EEEEEE");
    light.roundButtonColor = QColor("#E0E0E0");
    light.textColor = QColor("#000000");
    light.subtextColor = QColor("#666666");
    light.headerColor = QColor("#4f46e5");
    light.buttonProgress = QColor("#19545C");
    light.menuTextColor = QColor("#eb8e3d");
    light.white = QColor("#FFFFFF");
    light.black = QColor("#000000");
    light.transparent = QColor(Qt::transparent);
    light.red = QColor("#d10210");
    m_themes["light"] = light;
    
    // Blue theme
    ThemeColors blue;
    blue.baseColor = QColor("#0a1929");
    blue.cardPanelColor = QColor("#132f4c");
    blue.innerCardColor = QColor("#173a5e");
    blue.roundButtonColor = QColor("#1e4976");
    blue.textColor = QColor("#FFFFFF");
    blue.subtextColor = QColor("#94a3b8");
    blue.headerColor = QColor("#3b82f6");
    blue.buttonProgress = QColor("#22c55e");
    blue.menuTextColor = QColor("#f59e0b");
    blue.white = QColor("#FFFFFF");
    blue.black = QColor("#000000");
    blue.transparent = QColor(Qt::transparent);
    blue.red = QColor("#ef4444");
    m_themes["blue"] = blue;
    
    // Purple theme
    ThemeColors purple;
    purple.baseColor = QColor("#1a1625");
    purple.cardPanelColor = QColor("#2d2640");
    purple.innerCardColor = QColor("#3d3356");
    purple.roundButtonColor = QColor("#4a4069");
    purple.textColor = QColor("#FFFFFF");
    purple.subtextColor = QColor("#a78bfa");
    purple.headerColor = QColor("#8b5cf6");
    purple.buttonProgress = QColor("#10b981");
    purple.menuTextColor = QColor("#f472b6");
    purple.white = QColor("#FFFFFF");
    purple.black = QColor("#000000");
    purple.transparent = QColor(Qt::transparent);
    purple.red = QColor("#f43f5e");
    m_themes["purple"] = purple;

    // Forest theme
    ThemeColors forest;
    forest.baseColor = QColor("#0d1f12");
    forest.cardPanelColor = QColor("#1a3a22");
    forest.innerCardColor = QColor("#234d2d");
    forest.roundButtonColor = QColor("#2d6039");
    forest.textColor = QColor("#FFFFFF");
    forest.subtextColor = QColor("#8bc49a");
    forest.headerColor = QColor("#22c55e");
    forest.buttonProgress = QColor("#10b981");
    forest.menuTextColor = QColor("#fbbf24");
    forest.white = QColor("#FFFFFF");
    forest.black = QColor("#000000");
    forest.transparent = QColor(Qt::transparent);
    forest.red = QColor("#ef4444");
    m_themes["forest"] = forest;
}

void ThemeManager::loadThemeColors()
{
    if (m_themes.contains(m_currentTheme)) {
        m_currentColors = m_themes[m_currentTheme];
    } else {
        m_currentColors = m_themes["dark"];
    }
}

QString ThemeManager::currentTheme() const
{
    return m_currentTheme;
}

void ThemeManager::setCurrentTheme(const QString &themeName)
{
    if (m_currentTheme != themeName && m_themes.contains(themeName)) {
        m_currentTheme = themeName;
        loadThemeColors();
        emit currentThemeChanged();
        emit themeColorsChanged();
        qDebug() << "Theme changed to:" << themeName;
    }
}

QStringList ThemeManager::availableThemes() const
{
    return m_themes.keys();
}

bool ThemeManager::isDarkTheme() const
{
    return m_currentTheme != "light";
}

// Color getters
QColor ThemeManager::baseColor() const { return m_currentColors.baseColor; }
QColor ThemeManager::cardPanelColor() const { return m_currentColors.cardPanelColor; }
QColor ThemeManager::innerCardColor() const { return m_currentColors.innerCardColor; }
QColor ThemeManager::roundButtonColor() const { return m_currentColors.roundButtonColor; }
QColor ThemeManager::textColor() const { return m_currentColors.textColor; }
QColor ThemeManager::subtextColor() const { return m_currentColors.subtextColor; }
QColor ThemeManager::headerColor() const { return m_currentColors.headerColor; }
QColor ThemeManager::buttonProgress() const { return m_currentColors.buttonProgress; }
QColor ThemeManager::menuTextColor() const { return m_currentColors.menuTextColor; }
QColor ThemeManager::white() const { return m_currentColors.white; }
QColor ThemeManager::black() const { return m_currentColors.black; }
QColor ThemeManager::transparent() const { return m_currentColors.transparent; }
QColor ThemeManager::red() const { return m_currentColors.red; }

void ThemeManager::addTheme(const QString &themeName, const QVariantMap &colors)
{
    ThemeColors theme;
    theme.baseColor = QColor(colors.value("baseColor", "#000000").toString());
    theme.cardPanelColor = QColor(colors.value("cardPanelColor", "#1a2942").toString());
    theme.innerCardColor = QColor(colors.value("innerCardColor", "#223548").toString());
    theme.roundButtonColor = QColor(colors.value("roundButtonColor", "#2a3f5f").toString());
    theme.textColor = QColor(colors.value("textColor", "#FFFFFF").toString());
    theme.subtextColor = QColor(colors.value("subtextColor", "#7a8fa8").toString());
    theme.headerColor = QColor(colors.value("headerColor", "#6366f1").toString());
    theme.buttonProgress = QColor(colors.value("buttonProgress", "#28C878").toString());
    theme.menuTextColor = QColor(colors.value("menuTextColor", "#eb8e3d").toString());
    theme.white = QColor("#FFFFFF");
    theme.black = QColor("#000000");
    theme.transparent = QColor(Qt::transparent);
    theme.red = QColor(colors.value("red", "#fc0022").toString());
    
    m_themes[themeName] = theme;
    emit availableThemesChanged();
}

QVariantMap ThemeManager::getThemeColors(const QString &themeName) const
{
    QVariantMap result;
    if (m_themes.contains(themeName)) {
        const ThemeColors &theme = m_themes[themeName];
        result["baseColor"] = theme.baseColor.name();
        result["cardPanelColor"] = theme.cardPanelColor.name();
        result["innerCardColor"] = theme.innerCardColor.name();
        result["roundButtonColor"] = theme.roundButtonColor.name();
        result["textColor"] = theme.textColor.name();
        result["subtextColor"] = theme.subtextColor.name();
        result["headerColor"] = theme.headerColor.name();
        result["buttonProgress"] = theme.buttonProgress.name();
        result["menuTextColor"] = theme.menuTextColor.name();
        result["red"] = theme.red.name();
    }
    return result;
}
