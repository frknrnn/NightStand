#include "storageservice.h"
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QDebug>

StorageService* StorageService::m_instance = nullptr;

StorageService::StorageService(QObject *parent)
    : QObject(parent)
{
    // Set user data path to app data location + /user
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    m_userDataPath = appDataPath + "/user";
    
    initUserDataDirectory();
}

StorageService::~StorageService()
{
}

StorageService* StorageService::instance()
{
    if (!m_instance) {
        m_instance = new StorageService();
    }
    return m_instance;
}

QString StorageService::userDataPath() const
{
    return m_userDataPath;
}

QString StorageService::todoFilePath() const
{
    return m_userDataPath + "/todolist.json";
}

QString StorageService::alarmFilePath() const
{
    return m_userDataPath + "/alarmlist.json";
}

void StorageService::initUserDataDirectory()
{
    QDir dir(m_userDataPath);
    if (!dir.exists()) {
        if (dir.mkpath(m_userDataPath)) {
            qDebug() << "User data directory created:" << m_userDataPath;
        } else {
            qWarning() << "Failed to create user data directory:" << m_userDataPath;
        }
    }
}

QJsonDocument StorageService::loadJsonFile(const QString &filePath)
{
    QFile file(filePath);
    
    if (!file.exists()) {
        qDebug() << "File does not exist:" << filePath;
        return QJsonDocument();
    }
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open file for reading:" << filePath;
        return QJsonDocument();
    }
    
    QByteArray data = file.readAll();
    file.close();
    
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    
    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << parseError.errorString();
        return QJsonDocument();
    }
    
    return doc;
}

bool StorageService::saveJsonFile(const QString &filePath, const QJsonDocument &document)
{
    QFile file(filePath);
    
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Failed to open file for writing:" << filePath;
        return false;
    }
    
    QByteArray data = document.toJson(QJsonDocument::Indented);
    qint64 bytesWritten = file.write(data);
    file.close();
    
    if (bytesWritten == -1) {
        qWarning() << "Failed to write to file:" << filePath;
        return false;
    }
    
    qDebug() << "Successfully saved to:" << filePath;
    return true;
}

QJsonArray StorageService::loadTodos()
{
    QJsonDocument doc = loadJsonFile(todoFilePath());
    
    if (doc.isNull() || !doc.isArray()) {
        return QJsonArray();
    }
    
    return doc.array();
}

bool StorageService::saveTodos(const QJsonArray &todos)
{
    QJsonDocument doc(todos);
    return saveJsonFile(todoFilePath(), doc);
}

QJsonArray StorageService::loadAlarms()
{
    QJsonDocument doc = loadJsonFile(alarmFilePath());

    if (doc.isNull() || !doc.isArray()) {
        return QJsonArray();
    }

    return doc.array();
}

bool StorageService::saveAlarms(const QJsonArray &alarms)
{
    QJsonDocument doc(alarms);
    return saveJsonFile(alarmFilePath(), doc);
}
