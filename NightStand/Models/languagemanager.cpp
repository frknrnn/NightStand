#include "languagemanager.h"

#include <QCoreApplication>
#include <QDebug>
#include <QLocale>
#include <QSettings>
#include <QTranslator>
#include <QVariantMap>

LanguageManager* LanguageManager::m_instance = nullptr;

LanguageManager* LanguageManager::instance()
{
    if (!m_instance)
        m_instance = new LanguageManager();
    return m_instance;
}

LanguageManager::LanguageManager(QObject *parent)
    : QObject(parent)
{
    m_currentLanguage = restoreSavedLanguage();
    applyLanguage(m_currentLanguage);
    // No signal here: nothing is connected yet, and main.cpp seeds the engine
    // explicitly with currentLanguage() before engine.load().
}

LanguageManager::~LanguageManager()
{
    if (m_translator)
        QCoreApplication::removeTranslator(m_translator);
}

QVariantList LanguageManager::availableLanguages() const
{
    QVariantList out;
    out.append(QVariantMap{ { QStringLiteral("code"),  QStringLiteral("en") },
                            { QStringLiteral("label"), QStringLiteral("English") } });
    out.append(QVariantMap{ { QStringLiteral("code"),  QStringLiteral("tr") },
                            { QStringLiteral("label"), QStringLiteral("Türkçe") } });
    return out;
}

QString LanguageManager::localeName() const
{
    return localeNameFor(m_currentLanguage);
}

bool LanguageManager::isSupported(const QString &code) const
{
    return code == QLatin1String("en") || code == QLatin1String("tr");
}

QString LanguageManager::localeNameFor(const QString &code)
{
    if (code == QLatin1String("tr"))
        return QStringLiteral("tr_TR");
    return QStringLiteral("en_US");
}

QString LanguageManager::restoreSavedLanguage() const
{
    QSettings settings;                     // org/app name are set in main.cpp
    const QString saved = settings.value(QLatin1String(kSettingsKey)).toString();
    if (isSupported(saved))
        return saved;

    // First run: follow the device. uiLanguages() comes back in user preference
    // order, and QLocale normalises the "tr-TR" / "tr_TR" / "tr" spellings.
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &tag : uiLanguages) {
        const QString code = QLocale(tag).name().left(2);
        if (isSupported(code))
            return code;
    }

    return QString::fromLatin1(kFallback);
}

void LanguageManager::applyLanguage(const QString &code)
{
    // Locale first, translator second: installTranslator() posts a
    // QEvent::LanguageChange to qApp, and anything reacting to it must already
    // see the new QLocale.
    QLocale::setDefault(QLocale(localeNameFor(code)));

    // One translator at a time. Leaving the old one installed would let a source
    // string that only the previous catalogue knows still resolve.
    if (m_translator) {
        QCoreApplication::removeTranslator(m_translator);
        delete m_translator;
        m_translator = nullptr;
    }

    // No special case for the source language: if the catalogue is missing or
    // empty, load() returns false and we run on the source text - which for
    // "en" is exactly right.
    auto *translator = new QTranslator(this);
    if (translator->load(QStringLiteral(":/i18n/NightStand_%1.qm").arg(code))) {
        QCoreApplication::installTranslator(translator);
        m_translator = translator;
        return;
    }

    delete translator;
    if (code != QLatin1String(kFallback))
        qWarning() << "LanguageManager: no catalogue for" << code << "- using source text";
}

void LanguageManager::setCurrentLanguage(const QString &code)
{
    if (!isSupported(code) || code == m_currentLanguage)
        return;

    m_currentLanguage = code;
    applyLanguage(code);
    QSettings().setValue(QLatin1String(kSettingsKey), code);
    ++m_retranslateCount;
    emit currentLanguageChanged();
}
