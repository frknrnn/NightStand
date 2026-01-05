#ifndef STORAGESERVICE_H
#define STORAGESERVICE_H

#include <QObject>
#include <QString>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

class StorageService : public QObject
{
    Q_OBJECT
public:
    static StorageService* instance();

    // File paths
    QString userDataPath() const;
    QString todoFilePath() const;
    QString alarmFilePath() const;

    // Generic JSON operations
    QJsonDocument loadJsonFile(const QString &filePath);
    bool saveJsonFile(const QString &filePath, const QJsonDocument &document);

    // Todo specific operations
    QJsonArray loadTodos();
    bool saveTodos(const QJsonArray &todos);

    // Initialize user data directory
    void initUserDataDirectory();

private:
    explicit StorageService(QObject *parent = nullptr);
    ~StorageService();
    static StorageService* m_instance;
    Q_DISABLE_COPY(StorageService)

    QString m_userDataPath;
};

#endif // STORAGESERVICE_H
