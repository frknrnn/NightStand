#ifndef LANGUAGEMANAGER_H
#define LANGUAGEMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>

class QTranslator;

// Owns the application language: the persisted choice, the QTranslator installed
// on qApp, and the process-wide default QLocale.
//
// It deliberately knows nothing about QQmlApplicationEngine. main.cpp connects
// currentLanguageChanged() to the engine's setUiLanguage()/retranslate(). That
// keeps this constructible *before* the engine exists, which it must be: the
// first QML load has to already see the right translator.
class LanguageManager : public QObject
{
    Q_OBJECT

    // ISO code, "en" or "tr". Writable from QML; the setter both persists and
    // swaps the translator, so QML never has to do a dual write the way
    // UiStyle.setTheme() does.
    Q_PROPERTY(QString currentLanguage READ currentLanguage WRITE setCurrentLanguage
               NOTIFY currentLanguageChanged)

    // [{ code: "en", label: "English" }, { code: "tr", label: "Türkçe" }]
    // Native names, never translated - a language picker has to be readable by
    // someone who cannot read the language currently in use.
    Q_PROPERTY(QVariantList availableLanguages READ availableLanguages CONSTANT)

    // "en_US" / "tr_TR", for Qt.locale() in QML. DateDisplay.qml binds to this:
    // a bare Qt.locale() would return the right locale but create no dependency,
    // so the binding would never re-evaluate on a switch.
    Q_PROPERTY(QString localeName READ localeName NOTIFY currentLanguageChanged)

    // Bumped on every successful switch. Nothing uses it today; it is the escape
    // hatch for a binding that QQmlEngine::retranslate() fails to refresh - such
    // a binding can reference it to gain an explicit dependency.
    Q_PROPERTY(int retranslateCount READ retranslateCount NOTIFY currentLanguageChanged)

public:
    static LanguageManager* instance();

    QString currentLanguage() const { return m_currentLanguage; }
    void setCurrentLanguage(const QString &code);

    QVariantList availableLanguages() const;
    QString localeName() const;
    int retranslateCount() const { return m_retranslateCount; }

    // True for "en"/"tr". Used to reject junk from QSettings instead of silently
    // ending up with no translator at all.
    Q_INVOKABLE bool isSupported(const QString &code) const;

signals:
    // Emitted *after* the translator swap and QLocale::setDefault(), so every
    // slot may assume the new language is already live.
    void currentLanguageChanged();

private:
    explicit LanguageManager(QObject *parent = nullptr);
    ~LanguageManager();
    static LanguageManager* m_instance;
    Q_DISABLE_COPY(LanguageManager)

    // QSettings, then the system language, then "en". Deliberately done in C++:
    // ThemeManager hard-codes its default and never reads QSettings back, which
    // is why UiSettings.themeName is written but never restored. Not repeated here.
    QString restoreSavedLanguage() const;

    // Removes the previous translator, loads :/i18n/NightStand_<code>.qm and
    // installs it. Does not emit; the caller emits once, after persisting.
    void applyLanguage(const QString &code);

    static QString localeNameFor(const QString &code);

    static constexpr const char *kSettingsKey = "language";
    static constexpr const char *kFallback = "en";

    QString m_currentLanguage;
    QTranslator *m_translator = nullptr;   // owned; at most one installed at a time
    int m_retranslateCount = 0;
};

#endif // LANGUAGEMANAGER_H
