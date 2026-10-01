#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include "Models/modelmanager.h"
#include "Models/thememanager.h"
#include "Models/wifimanager.h"
#include "Models/languagemanager.h"
#include "ViewModels/appcontroller.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QGuiApplication app(argc, argv);

    // QSettings (UiSettings) bu isimler olmadan "Unknown Organization" altına yazıyor
    QCoreApplication::setOrganizationName("NightStand");
    QCoreApplication::setApplicationName("NightStand");

    // On the Pi the UI is scaled onto the panel with QT_SCALE_FACTOR (see
    // deploy/raspberrypi/nightstand.service). Logged once so the effective
    // scaling can be checked in the journal: the logical size is what QML
    // lays out against, the ratio is how far it is shrunk to fit the pixels.
    if (const QScreen *screen = QGuiApplication::primaryScreen())
        qInfo() << "Screen" << screen->name() << "logical size" << screen->size()
                << "devicePixelRatio" << screen->devicePixelRatio();

    QQmlApplicationEngine engine;

    ModelManager* mngr = ModelManager::instance();
    ThemeManager* themeManager = ThemeManager::instance();
    WifiManager* wifiManager = WifiManager::instance();
    LanguageManager* languageManager = LanguageManager::instance();
    AppController appController;
    
    engine.rootContext()->setContextProperty("appController", &appController);
    engine.rootContext()->setContextProperty("dateTimeViewModel", appController.getDateTimeViewModel());
    engine.rootContext()->setContextProperty("todoViewModel", appController.getTodoViewModel());
    engine.rootContext()->setContextProperty("alarmViewModel", appController.getAlarmViewModel());
    engine.rootContext()->setContextProperty("timerViewModel", appController.getTimerViewModel());
    engine.rootContext()->setContextProperty("calculatorViewModel", appController.getCalculatorViewModel());
    engine.rootContext()->setContextProperty("themeManager", themeManager);
    engine.rootContext()->setContextProperty("wifiManager", wifiManager);
    engine.rootContext()->setContextProperty("languageManager", languageManager);

    // Language switching. LanguageManager installs the translator; the engine has
    // to be told to re-evaluate every binding that ran a translation function.
    // Seeded before load() so the first frame is already in the right language.
    //
    // setUiLanguage() alone triggers retranslate() on a QQmlApplicationEngine,
    // but calling it explicitly is idempotent and removes the dependence on that
    // implementation detail. Setting it also keeps Qt.uiLanguage honest in QML.
    engine.setUiLanguage(languageManager->currentLanguage());
    QObject::connect(languageManager, &LanguageManager::currentLanguageChanged,
                     &engine, [&engine, languageManager]() {
                         engine.setUiLanguage(languageManager->currentLanguage());
                         engine.retranslate();
                     });

    const QUrl url(u"qrc:/NightStand/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
