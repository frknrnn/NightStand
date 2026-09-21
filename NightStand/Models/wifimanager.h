#ifndef WIFIMANAGER_H
#define WIFIMANAGER_H

#include <QObject>
#include <QHash>
#include <QPointer>
#include <QProcessEnvironment>
#include <QSet>
#include <QString>
#include <QStringList>
#include <QTimer>

#include "wifinetworkmodel.h"

class QProcess;

// Drives NetworkManager through nmcli, asynchronously. Every command is a
// short-lived child process; nothing ever blocks the GUI thread.
//
// On Windows (and on any Linux without nmcli, without a Wi-Fi device, or with
// NetworkManager stopped) supported() is false, the poll timer never starts and
// not a single process is ever spawned. The feature simply disappears from the UI.
class WifiManager : public QObject
{
    Q_OBJECT

    // False on Windows, and on Linux without nmcli in PATH or without a Wi-Fi
    // device. QML hides the top-bar button entirely when this is false.
    Q_PROPERTY(bool supported READ supported NOTIFY supportedChanged)

    // Radio (rfkill) switch. Writing is async: the property only flips once
    // nmcli confirms, so the toggle never lies about the real state.
    Q_PROPERTY(bool radioOn READ radioOn NOTIFY stateChanged)

    // Named wifiState (not state) so it never collides with Item.state in QML.
    Q_PROPERTY(int wifiState READ wifiState NOTIFY stateChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY stateChanged)
    Q_PROPERTY(bool connecting READ connecting NOTIFY stateChanged)
    Q_PROPERTY(QString currentSsid READ currentSsid NOTIFY stateChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY stateChanged)

    // Signal moves far more often than state: a separate notify lets the top-bar
    // icon refresh without re-evaluating every other binding.
    Q_PROPERTY(int currentSignal READ currentSignal NOTIFY signalChanged)  // 0-100, -1 unknown
    Q_PROPERTY(int signalBars READ signalBars NOTIFY signalChanged)        // 0-4

    // Roles: ssid, signalStrength, bars, security, secured, enterprise, active, saved
    Q_PROPERTY(QAbstractListModel* networks READ networks CONSTANT)
    Q_PROPERTY(int networkCount READ networkCount NOTIFY networksChanged)

    // Kayıtlı profil listesi. Popup detay paneli "Bağlan mı, şifre mi sorayım"
    // kararını buradan veriyor; connect/forget sonrası kendiliğinden tazeleniyor.
    Q_PROPERTY(QStringList savedSsids READ savedSsids NOTIFY savedNetworksChanged)

    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)

    // A user command (connect/disconnect/forget/radio) is in flight: QML disables
    // the buttons and shows progress on the pendingSsid row.
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString pendingSsid READ pendingSsid NOTIFY busyChanged)

    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    enum State {
        Unsupported  = 0,   // no nmcli / no device / NetworkManager not running
        RadioOff     = 1,
        Disconnected = 2,
        Connecting   = 3,
        Connected    = 4
    };
    Q_ENUM(State)

    static WifiManager* instance();

    bool supported() const { return m_supported; }
    bool radioOn() const { return m_radioOn; }
    int wifiState() const { return static_cast<int>(m_state); }
    bool connected() const { return m_state == Connected; }
    bool connecting() const { return m_state == Connecting; }
    QString currentSsid() const { return m_currentSsid; }
    QString statusText() const;
    int currentSignal() const { return m_currentSignal; }
    int signalBars() const { return WifiNetworkModel::barsFromSignal(m_currentSignal); }

    QAbstractListModel* networks() const;
    int networkCount() const;

    QStringList savedSsids() const;

    bool scanning() const { return m_scanning; }
    bool busy() const { return m_commandBusy; }
    QString pendingSsid() const { return m_pendingSsid; }
    QString lastError() const { return m_lastError; }

    // Commands. All become a no-op with lastError set when !supported.
    Q_INVOKABLE void setRadioEnabled(bool on);
    Q_INVOKABLE void toggleRadio();
    Q_INVOKABLE void scan();                                     // forced rescan
    Q_INVOKABLE void refresh();                                  // cached list, no rescan
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password);
    Q_INVOKABLE void connectToSaved(const QString &ssid);        // saved profile or open AP
    Q_INVOKABLE void disconnectCurrent();
    Q_INVOKABLE void forgetNetwork(const QString &ssid);
    Q_INVOKABLE bool isSaved(const QString &ssid) const;
    Q_INVOKABLE void clearError();

    // Poll faster while the Wi-Fi popup is on screen; back off when it closes.
    Q_INVOKABLE void setPopupOpen(bool open);

signals:
    void supportedChanged();
    void stateChanged();
    void signalChanged();
    void networksChanged();
    void savedNetworksChanged();
    void scanningChanged();
    void busyChanged();
    void lastErrorChanged();

    void connectSucceeded(const QString &ssid);
    // authError == true means wrong password - QML keeps the password field
    // open and shows the message inline instead of closing the dialog.
    void connectFailed(const QString &ssid, const QString &message, bool authError);

private slots:
    void onPollTick();

private:
    explicit WifiManager(QObject *parent = nullptr);
    ~WifiManager();
    static WifiManager* m_instance;
    Q_DISABLE_COPY(WifiManager)

    enum Job {
        JobProbe, JobGeneral, JobDeviceStatus, JobList,
        JobSaved, JobRadio, JobConnect, JobDisconnect, JobForget, JobCleanup
    };

    // ---- process plumbing
    void probeSupport();
    QProcess* startNmcli(Job job, const QStringList &args, int timeoutMs);
    void onJobFinished(Job job, int exitCode, bool timedOut,
                       const QString &out, const QString &err);
    void killAll();

    // ---- poll state machine
    void advancePoll();
    void applyPollInterval();
    void kickPoll();                 // immediate poll after a command lands
    bool guardCommand();             // false (and sets lastError) when unusable

    // ---- parsing
    static QStringList splitTerse(const QString &line);   // splits AND unescapes
    void parseGeneral(const QString &out);
    void parseDeviceStatus(const QString &out);
    void parseWifiList(const QString &out, bool fullReset);
    void parseSavedList(const QString &out);
    QString humanError(Job job, int exitCode, const QString &err, bool timedOut) const;
    static bool looksLikeAuthFailure(int exitCode, const QString &err);
    static bool looksLikeNotAuthorized(const QString &err);
    static QStringList redactArgs(const QStringList &args);   // never log the psk

    // ---- setters
    void setSupported(bool v);
    void setState(State s);
    void setCurrentSignal(int v);
    void setScanning(bool v);
    void setCommandBusy(bool v, const QString &ssid = QString());
    void setLastError(const QString &msg);

    static constexpr int kIdlePollMs       = 10000;  // top-bar icon only
    static constexpr int kActivePollMs     = 3000;   // popup open
    static constexpr int kConnectPollMs    = 1000;   // burst while connecting
    static constexpr int kBackoffPollMs    = 30000;  // NetworkManager not answering
    static constexpr int kConnectBurstMs   = 30000;  // how long the 1 Hz burst lasts
    static constexpr int kShortTimeoutMs   = 5000;
    static constexpr int kListTimeoutMs    = 15000;  // --rescan yes takes ~10 s
    static constexpr int kCommandTimeoutMs = 35000;  // nmcli -w 25 should return first
    static constexpr int kNmcliWaitSec     = 25;
    static constexpr int kMaxSpawnFailures = 3;

    QString m_nmcliPath;
    QProcessEnvironment m_env;                  // LC_ALL=C - error strings must be English
    QHash<int, QPointer<QProcess>> m_running;   // at most one process per Job kind
    QSet<QProcess*> m_timedOut;

    bool m_supported = false;
    bool m_radioOn = false;
    bool m_hardwareBlocked = false;
    State m_state = Unsupported;
    QString m_device;                           // e.g. wlan0
    QString m_currentSsid;
    int m_currentSignal = -1;
    QString m_connectivity;                     // full / limited / portal / none
    QString m_unsupportedReason;                // why supported() is false, for the UI

    // A failed connect that needs its stale profile deleted first reports only
    // once the cleanup lands, so a retry can never race the delete.
    QString m_cleanupFailSsid;
    QString m_cleanupFailMessage;

    WifiNetworkModel *m_networks;
    QHash<QString, QString> m_savedUuidBySsid;  // ssid -> profile uuid
    QSet<QString> m_ssidsWeCreated;             // for cleanup after an auth failure

    bool m_scanning = false;
    bool m_commandBusy = false;
    QString m_pendingSsid;
    QString m_lastError;

    QTimer m_poll;
    int m_pollStage = 0;                        // 0 idle, 1 general, 2 device, 3 list, 4 saved
    bool m_popupOpen = false;
    bool m_savedDirty = true;
    int m_spawnFailures = 0;
    qint64 m_connectStartedMs = 0;
};

#endif // WIFIMANAGER_H
