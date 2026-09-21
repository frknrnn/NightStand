#include "wifimanager.h"

#include <QDateTime>
#include <QDebug>
#include <QProcess>
#include <QStandardPaths>

WifiManager* WifiManager::m_instance = nullptr;

WifiManager* WifiManager::instance()
{
    if (!m_instance)
        m_instance = new WifiManager();
    return m_instance;
}

WifiManager::WifiManager(QObject *parent)
    : QObject(parent)
    , m_networks(new WifiNetworkModel(this))
{
    // nmcli localizes device STATE strings and error messages. On a Turkish
    // locale "connected" becomes "bagli" and both the state mapping and the
    // wrong-password detection stop matching. Pin the child to the C locale.
    m_env = QProcessEnvironment::systemEnvironment();
    m_env.insert(QStringLiteral("LC_ALL"), QStringLiteral("C"));
    m_env.insert(QStringLiteral("LANG"), QStringLiteral("C"));

    m_poll.setTimerType(Qt::CoarseTimer);   // exact milliseconds are irrelevant here
    connect(&m_poll, &QTimer::timeout, this, &WifiManager::onPollTick);

    // Deferred: never fork before the event loop is up, so application startup
    // and the first QML frame are not held back by nmcli.
    QTimer::singleShot(0, this, [this]() { probeSupport(); });
}

WifiManager::~WifiManager()
{
    killAll();
}

QAbstractListModel* WifiManager::networks() const
{
    return m_networks;
}

QStringList WifiManager::savedSsids() const
{
    QStringList out = m_savedUuidBySsid.keys();
    out.sort(Qt::CaseInsensitive);
    return out;
}

int WifiManager::networkCount() const
{
    return m_networks->rowCount();
}

QString WifiManager::statusText() const
{
    switch (m_state) {
    case Unsupported:
        return m_unsupportedReason.isEmpty() ? tr("Wi-Fi kullanılamıyor")
                                             : m_unsupportedReason;
    case RadioOff:
        return m_hardwareBlocked ? tr("Wi-Fi donanım anahtarıyla kapatılmış")
                                 : tr("Wi-Fi kapalı");
    case Disconnected:
        return tr("Bağlı değil");
    case Connecting:
        return m_currentSsid.isEmpty() ? tr("Bağlanıyor…")
                                       : tr("%1 ağına bağlanıyor…").arg(m_currentSsid);
    case Connected:
        if (m_connectivity == QLatin1String("portal"))
            return tr("%1 · oturum açma gerekiyor").arg(m_currentSsid);
        if (m_connectivity == QLatin1String("limited") || m_connectivity == QLatin1String("none"))
            return tr("%1 · internet yok").arg(m_currentSsid);
        if (m_currentSignal >= 0)
            return tr("%1 · sinyal %2").arg(m_currentSsid,
                                            QString::number(m_currentSignal) + QLatin1Char('%'));
        return m_currentSsid;
    }
    return QString();
}

// ---------------------------------------------------------------- process plumbing

void WifiManager::probeSupport()
{
#ifdef Q_OS_LINUX
    m_nmcliPath = QStandardPaths::findExecutable(QStringLiteral("nmcli"));
#else
    // Nothing to drive here. Kept as the only platform branch in the class so the
    // rest of the nmcli code still gets compiled (and type-checked) on Windows.
    m_nmcliPath.clear();
#endif

    if (m_nmcliPath.isEmpty()) {
        m_unsupportedReason = tr("Bu sistemde Wi-Fi yönetimi kullanılamıyor.");
        setSupported(false);
        setState(Unsupported);
        m_poll.stop();
        return;
    }

    startNmcli(JobProbe, { QStringLiteral("-t"), QStringLiteral("-f"),
                           QStringLiteral("DEVICE,TYPE,STATE,CONNECTION"),
                           QStringLiteral("device"), QStringLiteral("status") },
               kShortTimeoutMs);
}

QProcess* WifiManager::startNmcli(Job job, const QStringList &args, int timeoutMs)
{
    if (m_nmcliPath.isEmpty())
        return nullptr;

    // At most one process per job kind, ever. A hung nmcli must not let the poll
    // timer stack up a new child every few seconds.
    if (m_running.contains(job) && !m_running.value(job).isNull())
        return nullptr;

    QProcess *p = new QProcess(this);
    p->setProcessEnvironment(m_env);
    p->setProcessChannelMode(QProcess::SeparateChannels);   // error text lives on stderr
    m_running.insert(job, p);

    // Watchdog, parented to the process so it dies with it.
    QTimer *guard = new QTimer(p);
    guard->setSingleShot(true);
    connect(guard, &QTimer::timeout, p, [this, p]() {
        m_timedOut.insert(p);
        p->kill();          // -> finished(CrashExit) -> the normal handler path
    });
    guard->start(timeoutMs);

    // Redacted up front: the psk must never reach a log, and the lambda below
    // outlives this call.
    const QStringList logArgs = redactArgs(args);

    connect(p, &QProcess::errorOccurred, this, [this, job, p, logArgs](QProcess::ProcessError e) {
        if (e != QProcess::FailedToStart)
            return;                         // everything else arrives via finished()
        qWarning() << "WifiManager: nmcli başlatılamadı:" << logArgs;
        m_running.remove(job);
        if (++m_spawnFailures >= kMaxSpawnFailures) {
            m_unsupportedReason = tr("nmcli çalıştırılamıyor.");
            setSupported(false);
            setState(Unsupported);
            m_poll.stop();
        }
        m_pollStage = 0;
        setScanning(false);
        setCommandBusy(false);
        p->deleteLater();
    });

    connect(p, &QProcess::finished, this, [this, job, p](int code, QProcess::ExitStatus) {
        const bool timedOut = m_timedOut.remove(p) > 0;
        const QString out = QString::fromUtf8(p->readAllStandardOutput());
        const QString err = QString::fromUtf8(p->readAllStandardError());
        m_running.remove(job);
        m_spawnFailures = 0;
        p->deleteLater();
        onJobFinished(job, code, timedOut, out, err);
    });

    p->start(m_nmcliPath, args);
    return p;
}

void WifiManager::killAll()
{
    const QList<QPointer<QProcess>> procs = m_running.values();
    m_running.clear();
    for (const QPointer<QProcess> &p : procs) {
        if (p.isNull())
            continue;
        p->disconnect(this);        // no callbacks while we are tearing down
        p->kill();
        // Blocking is fine here: the app is already shutting down, this is not a
        // live UI frame, and the child has just been SIGKILLed.
        p->waitForFinished(100);
    }
    m_timedOut.clear();
}

void WifiManager::onJobFinished(Job job, int exitCode, bool timedOut,
                                const QString &out, const QString &err)
{
    const bool ok = (exitCode == 0 && !timedOut);

    switch (job) {
    case JobProbe:
        if (ok) {
            parseDeviceStatus(out);
            if (m_device.isEmpty()) {
                setSupported(false);
                setState(Unsupported);
                // A USB dongle may show up later, so keep looking, slowly.
                m_poll.start(kBackoffPollMs);
            } else {
                m_unsupportedReason.clear();
                setSupported(true);
                m_savedDirty = true;
                applyPollInterval();
                kickPoll();
            }
        } else {
            m_unsupportedReason = humanError(job, exitCode, err, timedOut);
            setSupported(false);
            setState(Unsupported);
            m_poll.start(kBackoffPollMs);   // NetworkManager may come back
        }
        break;

    case JobGeneral:
        if (ok) {
            parseGeneral(out);
            advancePoll();
        } else {
            m_unsupportedReason = humanError(job, exitCode, err, timedOut);
            setLastError(m_unsupportedReason);
            if (exitCode == 8) {            // NetworkManager is not running
                setSupported(false);
                setState(Unsupported);
                m_poll.start(kBackoffPollMs);
            }
            m_pollStage = 0;
        }
        break;

    case JobDeviceStatus:
        if (ok) {
            parseDeviceStatus(out);
            if (m_device.isEmpty()) {
                setSupported(false);
                setState(Unsupported);
                m_poll.start(kBackoffPollMs);
                m_pollStage = 0;
                break;
            }
            advancePoll();
        } else {
            setLastError(humanError(job, exitCode, err, timedOut));
            m_pollStage = 0;
        }
        break;

    case JobList: {
        const bool wasUserScan = m_scanning;
        if (ok)
            parseWifiList(out, wasUserScan);
        else
            setLastError(humanError(job, exitCode, err, timedOut));
        setScanning(false);
        advancePoll();
        break;
    }

    case JobSaved:
        if (ok) {
            parseSavedList(out);
            m_savedDirty = false;
        }
        advancePoll();
        break;

    case JobRadio:
        setCommandBusy(false);
        if (!ok)
            setLastError(humanError(job, exitCode, err, timedOut));
        kickPoll();
        break;

    case JobConnect: {
        const QString ssid = m_pendingSsid;
        if (ok) {
            m_ssidsWeCreated.remove(ssid);
            m_savedDirty = true;
            setCommandBusy(false);
            setLastError(QString());
            emit connectSucceeded(ssid);
            kickPoll();
        } else {
            const bool auth = looksLikeAuthFailure(exitCode, err);
            const QString msg = auth ? tr("Yanlış şifre.")
                                     : humanError(job, exitCode, err, timedOut);

            // Some nmcli versions leave the half-created profile behind carrying
            // the wrong psk. The next attempt would reuse it and fail again, so
            // the UI would look stuck on "wrong password" forever. Delete it
            // first and report only afterwards, so a retry starts clean.
            if (auth && m_ssidsWeCreated.contains(ssid)) {
                m_ssidsWeCreated.remove(ssid);
                m_cleanupFailSsid = ssid;
                m_cleanupFailMessage = msg;
                m_savedDirty = true;
                if (startNmcli(JobCleanup, { QStringLiteral("connection"),
                                             QStringLiteral("delete"),
                                             QStringLiteral("id"), ssid },
                               kShortTimeoutMs)) {
                    break;                  // the cleanup handler emits connectFailed
                }
                m_cleanupFailSsid.clear();
                m_cleanupFailMessage.clear();
            }

            setCommandBusy(false);
            setLastError(msg);
            emit connectFailed(ssid, msg, auth);
            kickPoll();
        }
        applyPollInterval();
        break;
    }

    case JobCleanup: {
        const QString ssid = m_cleanupFailSsid;
        const QString msg = m_cleanupFailMessage;
        m_cleanupFailSsid.clear();
        m_cleanupFailMessage.clear();
        m_savedDirty = true;
        setCommandBusy(false);
        setLastError(msg);
        if (!ssid.isEmpty())
            emit connectFailed(ssid, msg, true);
        kickPoll();
        break;
    }

    case JobDisconnect:
        setCommandBusy(false);
        if (!ok)
            setLastError(humanError(job, exitCode, err, timedOut));
        kickPoll();
        break;

    case JobForget:
        setCommandBusy(false);
        if (ok)
            m_savedDirty = true;
        else
            setLastError(humanError(job, exitCode, err, timedOut));
        kickPoll();
        break;
    }
}

// ------------------------------------------------------------- poll state machine

void WifiManager::onPollTick()
{
    if (m_nmcliPath.isEmpty()) {
        m_poll.stop();
        return;
    }
    if (!m_supported) {
        probeSupport();             // backoff re-probe: NM or a dongle may be back
        return;
    }
    if (m_pollStage != 0)
        return;                     // the previous poll has not finished yet

    m_pollStage = 1;
    startNmcli(JobGeneral, { QStringLiteral("-t"), QStringLiteral("-f"),
                             QStringLiteral("STATE,CONNECTIVITY,WIFI-HW,WIFI"),
                             QStringLiteral("general") },
               kShortTimeoutMs);
}

void WifiManager::advancePoll()
{
    // Sequential chain: each finished stage picks the next one. Stages that are
    // skipped fall through, so a poll never stalls halfway.
    if (m_pollStage == 1) {
        if (!m_radioOn) {
            // Radio off - nothing else is worth asking.
            setState(RadioOff);
            setCurrentSignal(-1);
            if (!m_currentSsid.isEmpty()) {
                m_currentSsid.clear();
                emit stateChanged();
            }
            if (!m_networks->isEmpty()) {
                m_networks->clear();
                emit networksChanged();
            }
            m_pollStage = 0;
            applyPollInterval();
            return;
        }
        m_pollStage = 2;
        if (startNmcli(JobDeviceStatus, { QStringLiteral("-t"), QStringLiteral("-f"),
                                          QStringLiteral("DEVICE,TYPE,STATE,CONNECTION"),
                                          QStringLiteral("device"), QStringLiteral("status") },
                       kShortTimeoutMs)) {
            return;
        }
    }

    if (m_pollStage == 2) {
        m_pollStage = 3;
        // The AP list is by far the heaviest query. Skip it entirely while the
        // popup is closed - the top bar only needs state, not the list.
        if (m_popupOpen || m_networks->isEmpty()) {
            if (startNmcli(JobList, { QStringLiteral("-t"), QStringLiteral("-f"),
                                      QStringLiteral("ACTIVE,SSID,SIGNAL,SECURITY,BSSID"),
                                      QStringLiteral("device"), QStringLiteral("wifi"),
                                      QStringLiteral("list"), QStringLiteral("--rescan"),
                                      QStringLiteral("no") },
                           kListTimeoutMs)) {
                return;
            }
        }
    }

    if (m_pollStage == 3) {
        m_pollStage = 4;
        if (m_savedDirty) {
            if (startNmcli(JobSaved, { QStringLiteral("-t"), QStringLiteral("-f"),
                                       QStringLiteral("NAME,UUID,TYPE"),
                                       QStringLiteral("connection"), QStringLiteral("show") },
                           kShortTimeoutMs)) {
                return;
            }
        }
    }

    m_pollStage = 0;
    applyPollInterval();
}

void WifiManager::applyPollInterval()
{
    if (!m_supported || m_nmcliPath.isEmpty()) {
        if (m_nmcliPath.isEmpty())
            m_poll.stop();
        return;
    }

    int ms = m_popupOpen ? kActivePollMs : kIdlePollMs;
    if (m_state == Connecting
        && QDateTime::currentMSecsSinceEpoch() - m_connectStartedMs < kConnectBurstMs) {
        ms = kConnectPollMs;        // makes the moment after tapping Connect feel alive
    }
    if (m_spawnFailures > 0)
        ms = kBackoffPollMs;

    if (m_poll.interval() != ms || !m_poll.isActive())
        m_poll.start(ms);
}

void WifiManager::kickPoll()
{
    m_pollStage = 0;
    onPollTick();
}

bool WifiManager::guardCommand()
{
    if (!m_supported) {
        setLastError(m_unsupportedReason.isEmpty()
                     ? tr("Bu sistemde Wi-Fi yönetimi kullanılamıyor.")
                     : m_unsupportedReason);
        return false;
    }
    if (m_commandBusy)
        return false;               // one user command at a time
    return true;
}

// -------------------------------------------------------------------- parsing

QStringList WifiManager::splitTerse(const QString &line)
{
    // nmcli terse output escapes ':' as '\:' and '\' as '\\' inside fields.
    // SSIDs and every BSSID contain colons, so a plain split(':') is wrong.
    QStringList out;
    QString cur;
    for (int i = 0; i < line.size(); ++i) {
        const QChar c = line.at(i);
        if (c == QLatin1Char('\\') && i + 1 < line.size()) {
            cur.append(line.at(++i));
            continue;
        }
        if (c == QLatin1Char(':')) {
            out.append(cur);
            cur.clear();
            continue;
        }
        if (c == QLatin1Char('\r'))
            continue;
        cur.append(c);
    }
    out.append(cur);
    return out;
}

void WifiManager::parseGeneral(const QString &out)
{
    const QStringList lines = out.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    if (lines.isEmpty())
        return;

    const QStringList f = splitTerse(lines.first());
    if (f.count() < 4)
        return;

    m_connectivity = f.at(1);

    const bool blocked = (f.at(2) == QLatin1String("disabled"));
    const bool on = (f.at(3) == QLatin1String("enabled"));

    if (m_radioOn != on || m_hardwareBlocked != blocked) {
        m_radioOn = on;
        m_hardwareBlocked = blocked;
        emit stateChanged();

        // A hardware rfkill switch cannot be undone by `nmcli radio wifi on`, so
        // say so explicitly instead of letting the toggle look broken. Handled on
        // the transition only, so the message also clears when the switch is
        // flipped back - and so a poll does not keep re-asserting it.
        setLastError(m_hardwareBlocked ? tr("Wi-Fi donanım anahtarıyla kapatılmış.")
                                       : QString());
    }
}

void WifiManager::parseDeviceStatus(const QString &out)
{
    QString device;
    QString connName;
    State s = Disconnected;
    bool unmanaged = false;
    bool found = false;

    const QStringList lines = out.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const QStringList f = splitTerse(line);
        if (f.count() < 3)
            continue;
        // Exact match: "wifi-p2p" is a decoy row that startsWith("wifi") catches.
        if (f.at(1) != QLatin1String("wifi"))
            continue;

        device = f.at(0);
        connName = f.value(3);
        const QString st = f.at(2);

        if (st == QLatin1String("connected"))
            s = Connected;
        else if (st.startsWith(QLatin1String("connecting")))   // "connecting (getting IP configuration)"
            s = Connecting;
        else if (st == QLatin1String("unmanaged"))
            unmanaged = true;
        else if (st == QLatin1String("unavailable"))
            s = RadioOff;
        else
            s = Disconnected;                                  // disconnected / deactivating / failed

        found = true;
        break;                                                 // the first Wi-Fi device wins
    }

    if (!found) {
        m_device.clear();
        m_unsupportedReason = tr("Bu cihazda Wi-Fi donanımı bulunamadı.");
        return;
    }

    if (unmanaged) {
        // The Bullseye case: dhcpcd/wpa_supplicant own wlan0, NetworkManager does
        // not. Nothing we do here can work, so report it as unsupported.
        m_device.clear();
        m_unsupportedReason = tr("Wi-Fi cihazı NetworkManager tarafından yönetilmiyor.");
        return;
    }

    m_device = device;
    m_unsupportedReason.clear();

    const QString ssid = (s == Connected || s == Connecting) ? connName : QString();
    if (m_currentSsid != ssid) {
        m_currentSsid = ssid;
        emit stateChanged();
    }
    if (s != Connected)
        setCurrentSignal(-1);

    setState(s);
}

void WifiManager::parseWifiList(const QString &out, bool fullReset)
{
    QHash<QString, WifiNetwork> bySsid;
    QStringList order;                  // keeps first-seen order for merge()

    const QStringList lines = out.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const QStringList f = splitTerse(line);
        if (f.count() < 4)
            continue;

        WifiNetwork n;
        n.active = (f.at(0) == QLatin1String("yes"));
        n.ssid = f.at(1);
        if (n.ssid.isEmpty())
            continue;                   // hidden network: out of scope, and they
                                        // would all collapse into one blank row
        n.signal = f.at(2).toInt();
        n.security = f.at(3).trimmed();
        n.bssid = f.value(4);

        // The same SSID arrives once per BSSID (repeater / dual band). Keep the
        // strongest, OR the active flag, or the list shows it three times.
        auto it = bySsid.find(n.ssid);
        if (it == bySsid.end()) {
            bySsid.insert(n.ssid, n);
            order.append(n.ssid);
        } else {
            it->active = it->active || n.active;
            if (n.signal > it->signal) {
                it->signal = n.signal;
                it->bssid = n.bssid;
                it->security = n.security;
            }
        }
    }

    QList<WifiNetwork> list;
    list.reserve(order.count());
    int activeSignal = -1;
    for (const QString &ssid : order) {
        WifiNetwork n = bySsid.value(ssid);
        n.saved = m_savedUuidBySsid.contains(n.ssid);
        if (n.active)
            activeSignal = n.signal;
        list.append(n);
    }

    if (fullReset)
        m_networks->reset(list);
    else
        m_networks->merge(list);
    emit networksChanged();

    if (activeSignal >= 0)
        setCurrentSignal(activeSignal);
}

void WifiManager::parseSavedList(const QString &out)
{
    QHash<QString, QString> uuidByName;

    const QStringList lines = out.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const QStringList f = splitTerse(line);
        if (f.count() < 3)
            continue;
        if (f.at(2) != QLatin1String("802-11-wireless"))
            continue;
        // A profile name is not formally the SSID (that lives in
        // 802-11-wireless.ssid), but every profile nmcli, GNOME or this app
        // creates is named after its SSID. Reading the real one would cost an
        // extra process per profile, which is not worth it on a Pi.
        uuidByName.insert(f.at(0), f.at(1));
    }

    if (uuidByName == m_savedUuidBySsid)
        return;

    m_savedUuidBySsid = uuidByName;

    QSet<QString> ssids;
    for (auto it = m_savedUuidBySsid.constBegin(); it != m_savedUuidBySsid.constEnd(); ++it)
        ssids.insert(it.key());
    m_networks->applySaved(ssids);
    emit savedNetworksChanged();
}

bool WifiManager::looksLikeAuthFailure(int exitCode, const QString &err)
{
    // NM reason 7 = NO_SECRETS. A psk shorter than 8 characters is rejected by
    // nmcli at input validation time (exit 2), which is the same user mistake.
    return (exitCode == 4 && (err.contains(QLatin1String("Secrets were required"))
                              || err.contains(QLatin1String("(7)"))))
        || (exitCode == 2 && err.contains(QLatin1String("psk")));
}

bool WifiManager::looksLikeNotAuthorized(const QString &err)
{
    return err.contains(QLatin1String("not authorized"), Qt::CaseInsensitive)
        || err.contains(QLatin1String("Insufficient privileges"), Qt::CaseInsensitive);
}

QString WifiManager::humanError(Job job, int exitCode, const QString &err, bool timedOut) const
{
    Q_UNUSED(job)

    if (timedOut)
        return tr("İşlem zaman aşımına uğradı.");

    // Reads keep working without polkit authorization while writes all fail, so
    // "the list fills but Connect does nothing" is the fingerprint of this case.
    if (looksLikeNotAuthorized(err))
        return tr("Ağ ayarlarını değiştirme yetkisi yok (polkit).");

    switch (exitCode) {
    case 2:  return tr("Geçersiz giriş.");
    case 3:  return tr("NetworkManager zaman aşımına uğradı.");
    case 4:  return tr("Bağlantı kurulamadı.");
    case 5:  return tr("Bağlantı kesilemedi.");
    case 6:  return tr("Cihaz bağlantısı kesilemedi.");
    case 7:  return tr("Profil silinemedi.");
    case 8:  return tr("NetworkManager çalışmıyor.");
    case 10: return tr("Ağ bulunamadı.");
    default: break;
    }

    const QString firstLine = err.section(QLatin1Char('\n'), 0, 0).trimmed();
    return firstLine.isEmpty() ? tr("Bilinmeyen bir hata oluştu.") : firstLine;
}

QStringList WifiManager::redactArgs(const QStringList &args)
{
    QStringList out = args;
    const int i = out.indexOf(QStringLiteral("password"));
    if (i >= 0 && i + 1 < out.count())
        out[i + 1] = QStringLiteral("***");
    return out;
}

// ------------------------------------------------------------------- commands

void WifiManager::setRadioEnabled(bool on)
{
    if (!guardCommand())
        return;
    if (m_hardwareBlocked && on) {
        setLastError(tr("Wi-Fi donanım anahtarıyla kapatılmış."));
        return;
    }

    setLastError(QString());
    setCommandBusy(true);
    if (!startNmcli(JobRadio, { QStringLiteral("radio"), QStringLiteral("wifi"),
                                on ? QStringLiteral("on") : QStringLiteral("off") },
                    kShortTimeoutMs)) {
        setCommandBusy(false);
    }
}

void WifiManager::toggleRadio()
{
    setRadioEnabled(!m_radioOn);
}

void WifiManager::scan()
{
    if (!m_supported) {
        setLastError(m_unsupportedReason.isEmpty()
                     ? tr("Bu sistemde Wi-Fi yönetimi kullanılamıyor.")
                     : m_unsupportedReason);
        return;
    }
    if (m_scanning || !m_radioOn)
        return;

    setScanning(true);
    setLastError(QString());
    // --rescan yes does the rescan and the listing in one child process, so there
    // is no "wait N seconds then list" guesswork. It blocks the child, not us.
    if (!startNmcli(JobList, { QStringLiteral("-t"), QStringLiteral("-f"),
                               QStringLiteral("ACTIVE,SSID,SIGNAL,SECURITY,BSSID"),
                               QStringLiteral("device"), QStringLiteral("wifi"),
                               QStringLiteral("list"), QStringLiteral("--rescan"),
                               QStringLiteral("yes") },
                    kListTimeoutMs)) {
        setScanning(false);
    }
}

void WifiManager::refresh()
{
    if (!m_supported)
        return;
    kickPoll();
}

void WifiManager::connectToNetwork(const QString &ssid, const QString &password)
{
    if (ssid.isEmpty() || !guardCommand())
        return;

    const int row = m_networks->indexOfSsid(ssid);
    if (row >= 0 && m_networks->networkAt(row).security.contains(QLatin1String("802.1X"))) {
        setLastError(tr("Kurumsal (802.1X) ağlar desteklenmiyor."));
        return;
    }

    setLastError(QString());
    setCommandBusy(true, ssid);
    m_connectStartedMs = QDateTime::currentMSecsSinceEpoch();
    if (!m_savedUuidBySsid.contains(ssid))
        m_ssidsWeCreated.insert(ssid);

    // Note on the psk in argv: /proc/<pid>/cmdline is world readable for the few
    // seconds this child lives. Every alternative (connection add, --ask+stdin)
    // either keeps the psk in argv anyway or trades a known small exposure for a
    // fragile connect path. NetworkManager persists the same psk in
    // /etc/NetworkManager/system-connections regardless. Single-user appliance:
    // accepted deliberately. What we do avoid is ever logging it - see redactArgs().
    QStringList args{ QStringLiteral("-w"), QString::number(kNmcliWaitSec),
                      QStringLiteral("device"), QStringLiteral("wifi"),
                      QStringLiteral("connect"), ssid };
    if (!password.isEmpty())
        args << QStringLiteral("password") << password;
    if (!m_device.isEmpty())
        args << QStringLiteral("ifname") << m_device;

    if (!startNmcli(JobConnect, args, kCommandTimeoutMs)) {
        setCommandBusy(false);
        return;
    }
    applyPollInterval();
}

void WifiManager::connectToSaved(const QString &ssid)
{
    if (ssid.isEmpty() || !guardCommand())
        return;

    setLastError(QString());
    setCommandBusy(true, ssid);
    m_connectStartedMs = QDateTime::currentMSecsSinceEpoch();

    const QString uuid = m_savedUuidBySsid.value(ssid);
    QStringList args;
    if (!uuid.isEmpty()) {
        // uuid, not `id <name>`: profile names are not unique.
        args = { QStringLiteral("-w"), QString::number(kNmcliWaitSec),
                 QStringLiteral("connection"), QStringLiteral("up"),
                 QStringLiteral("uuid"), uuid };
    } else {
        args = { QStringLiteral("-w"), QString::number(kNmcliWaitSec),
                 QStringLiteral("device"), QStringLiteral("wifi"),
                 QStringLiteral("connect"), ssid };
        if (!m_device.isEmpty())
            args << QStringLiteral("ifname") << m_device;
    }

    if (!startNmcli(JobConnect, args, kCommandTimeoutMs)) {
        setCommandBusy(false);
        return;
    }
    applyPollInterval();
}

void WifiManager::disconnectCurrent()
{
    if (!guardCommand())
        return;
    if (m_device.isEmpty()) {
        setLastError(tr("Wi-Fi cihazı bulunamadı."));
        return;
    }

    setLastError(QString());
    setCommandBusy(true, m_currentSsid);
    // `device disconnect`, not `connection down`: the latter leaves the device
    // eligible for autoconnect, so NM reconnects within a second and the button
    // looks broken. This marks the device manually disconnected.
    if (!startNmcli(JobDisconnect, { QStringLiteral("device"),
                                     QStringLiteral("disconnect"), m_device },
                    kCommandTimeoutMs)) {
        setCommandBusy(false);
    }
}

void WifiManager::forgetNetwork(const QString &ssid)
{
    if (ssid.isEmpty() || !guardCommand())
        return;

    const QString uuid = m_savedUuidBySsid.value(ssid);
    if (uuid.isEmpty()) {
        setLastError(tr("Bu ağ için kayıtlı profil yok."));
        return;
    }

    setLastError(QString());
    setCommandBusy(true, ssid);
    m_ssidsWeCreated.remove(ssid);
    if (!startNmcli(JobForget, { QStringLiteral("connection"), QStringLiteral("delete"),
                                 QStringLiteral("uuid"), uuid },
                    kShortTimeoutMs)) {
        setCommandBusy(false);
    }
}

bool WifiManager::isSaved(const QString &ssid) const
{
    return m_savedUuidBySsid.contains(ssid);
}

void WifiManager::clearError()
{
    setLastError(QString());
}

void WifiManager::setPopupOpen(bool open)
{
    if (m_popupOpen == open)
        return;
    m_popupOpen = open;
    applyPollInterval();
    if (open)
        kickPoll();
}

// -------------------------------------------------------------------- setters

void WifiManager::setSupported(bool v)
{
    if (m_supported == v)
        return;
    m_supported = v;
    emit supportedChanged();
}

void WifiManager::setState(State s)
{
    if (m_state == s)
        return;
    m_state = s;
    emit stateChanged();
    applyPollInterval();        // entering/leaving Connecting changes the cadence
}

void WifiManager::setCurrentSignal(int v)
{
    if (m_currentSignal == v)
        return;
    m_currentSignal = v;
    emit signalChanged();
}

void WifiManager::setScanning(bool v)
{
    if (m_scanning == v)
        return;
    m_scanning = v;
    emit scanningChanged();
}

void WifiManager::setCommandBusy(bool v, const QString &ssid)
{
    const QString next = v ? ssid : QString();
    if (m_commandBusy == v && m_pendingSsid == next)
        return;
    m_commandBusy = v;
    m_pendingSsid = next;
    emit busyChanged();
}

void WifiManager::setLastError(const QString &msg)
{
    if (m_lastError == msg)
        return;
    m_lastError = msg;
    emit lastErrorChanged();
}
