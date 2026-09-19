#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Models/modelmanager.h"
#include "Models/thememanager.h"
#include "ViewModels/appcontroller.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QGuiApplication app(argc, argv);

    // QSettings (UiSettings) bu isimler olmadan "Unknown Organization" altına yazıyor
    QCoreApplication::setOrganizationName("NightStand");
    QCoreApplication::setApplicationName("NightStand");

    QQmlApplicationEngine engine;

    ModelManager* mngr = ModelManager::instance();
    ThemeManager* themeManager = ThemeManager::instance();
    AppController appController;
    
    engine.rootContext()->setContextProperty("appController", &appController);
    engine.rootContext()->setContextProperty("dateTimeViewModel", appController.getDateTimeViewModel());
    engine.rootContext()->setContextProperty("todoViewModel", appController.getTodoViewModel());
    engine.rootContext()->setContextProperty("alarmViewModel", appController.getAlarmViewModel());
    engine.rootContext()->setContextProperty("timerViewModel", appController.getTimerViewModel());
    engine.rootContext()->setContextProperty("themeManager", themeManager);

    const QUrl url(u"qrc:/NightStand/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
