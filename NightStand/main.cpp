#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Models/modelmanager.h"
#include "ViewModels/appcontroller.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    ModelManager* mngr = ModelManager::instance();
    AppController appController;
    engine.rootContext()->setContextProperty("dateTimeViewModel", appController.getDateTimeViewModel());
    engine.rootContext()->setContextProperty("todoViewModel", appController.getTodoViewModel());

    const QUrl url(u"qrc:/NightStand/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
