# Raspberry Pi kiosk kurulumu

NightStand'i masaüstü olmadan, açılışta doğrudan tam ekran çalıştırır
(Qt eglfs + systemd kullanıcı servisi).

Donanım: resmi 7" Raspberry Pi Touch Display (v1, 800x480, DSI kablosu,
`ft5x06` dokunmatik), cihazda ters monte edilmiş. Arayüz 1024x600 için
tasarlandı; panele `QT_SCALE_FACTOR=0.78125` ile ölçeklenir.

| Dosya | Ne işe yarar |
|---|---|
| `nightstand.service` | Uygulamayı eglfs ile başlatan, çökerse yeniden başlatan servis |
| `50-nightstand-networkmanager.rules` | Oturum yokken `nmcli` ile Wi-Fi bağlanma izni (polkit) |
| `99-nightstand-touch-rotate.rules` | Dokunmatiği 180° çevirir (udev, libinput) |
| `update.sh` | `git pull` + derleme + servisi yeniden başlatma |

Tüm komutlar Pi'de, SSH oturumunda çalıştırılır. Kullanıcı adı `nightstand`.

## 0. Hazırlık: işletim sistemi, paketler, derleme

Trixie tabanlı **Raspberry Pi OS (64-bit)** gerekir: proje Qt 6.7+ istiyor,
Bookworm'daki Qt 6.4 ile configure aşamasında hata verir.

```
sudo apt update && sudo apt full-upgrade -y
apt policy qt6-base-dev
```

`Candidate` sürümü 6.7 veya üstü olmalı. Paketler:

```
sudo apt install -y git cmake ninja-build build-essential \
  qt6-base-dev qt6-declarative-dev qt6-declarative-private-dev \
  qt6-multimedia-dev qt6-virtualkeyboard-dev \
  qt6-tools-dev qt6-tools-dev-tools qt6-l10n-tools qt6-wayland \
  qt6-svg-plugins qt6-virtualkeyboard-plugin \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
  qml6-module-qtquick-shapes qml6-module-qtquick-effects qml6-module-qtquick-templates \
  qml6-module-qtquick-window qml6-module-qtquick-virtualkeyboard \
  qml6-module-qtmultimedia qml6-module-qtcore qml6-module-qt-labs-settings \
  qml6-module-qtqml-workerscript
```

İki paket kolay gözden kaçar, uygulama derlenir ama eksik çalışır:

- `qt6-svg-plugins`: yoksa tüm ikonlar boş kalır (`Unsupported image format`).
- `qt6-virtualkeyboard-plugin`: yoksa metin alanına dokununca sanal klavye
  açılmaz. QML tarafı (`qml6-module-qtquick-virtualkeyboard`) tek başına
  yetmez; klavyeyi metin alanına bağlayan giriş eklentisi bu pakette.

Projeyi çek ve derle (derleme klasörü `build-pi`, `.gitignore` kapsamında):

```
git clone -b development https://github.com/frknrnn/NightStand.git ~/NightStand
cd ~/NightStand
cmake -S NightStand -B build-pi -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-pi -j4
```

## 1. Kontroller

```
ls /usr/lib/aarch64-linux-gnu/qt6/plugins/platforms/ | grep eglfs
ls /usr/lib/aarch64-linux-gnu/qt6/plugins/egldeviceintegrations/
ls /usr/lib/aarch64-linux-gnu/qt6/plugins/platforminputcontexts/
ls /usr/lib/aarch64-linux-gnu/qt6/plugins/imageformats/ | grep svg
groups
```

| Komut | Görmen gereken |
|---|---|
| `platforms` | `libqeglfs.so` |
| `egldeviceintegrations` | `libqeglfs-kms-integration.so` |
| `platforminputcontexts` | `libqtvirtualkeyboardplugin.so` |
| `imageformats` | `libqsvg.so` |
| `groups` | `video`, `render`, `input` (ekran ve dokunmatik erişimi) |

## 2. Polkit kuralı

```
sudo cp ~/NightStand/deploy/raspberrypi/50-nightstand-networkmanager.rules /etc/polkit-1/rules.d/
```

## 3. Ekranı 180° çevir

Ekran ters monte edildiği için hem görüntü hem dokunmatik çevrilir.
Qt'nin kendi `QT_QPA_EGLFS_ROTATION` ayarı Qt Quick uygulamalarında
**çalışmaz**, bu yüzden döndürme sistem seviyesinde yapılır.

**Görüntü** (`cmdline.txt` tek satırdır, önce yedek al):

```
sudo cp /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.rotate-bak
sudo sed -i '1 s/$/ video=DSI-1:800x480@60,rotate=180/' /boot/firmware/cmdline.txt
cat /boot/firmware/cmdline.txt
```

**Dokunmatik** (libinput kalibrasyon matrisi):

```
sudo cp ~/NightStand/deploy/raspberrypi/99-nightstand-touch-rotate.rules /etc/udev/rules.d/
sudo reboot
```

Açılışta konsol yazıları ters dönmüş olmalı.

> **Doğrulanmadı:** `rotate=180`'in eglfs'te uygulamanın görüntüsünü de
> çevirdiği 4. adımda test edilecek. Sadece konsol dönüp uygulama ters
> kalırsa plan, eglfs yerine `cage` kiosk compositor'ına geçmek: döndürmeyi
> o yapar, dokunmatiği de kendisi çevirir. Bu durumda `cmdline.txt` yedeğe
> döndürülür ve udev kuralı silinir.

Geri almak için:

```
sudo cp /boot/firmware/cmdline.txt.rotate-bak /boot/firmware/cmdline.txt
sudo rm /etc/udev/rules.d/99-nightstand-touch-rotate.rules
sudo reboot
```

## 4. Elle test (masaüstü geçici olarak kapalı)

Ekranı masaüstü tuttuğu sürece eglfs çizemez, önce onu durdur (servis
kuruluysa onu da):

```
systemctl --user stop nightstand 2>/dev/null
sudo systemctl stop lightdm
cd ~/NightStand
QT_QPA_PLATFORM=eglfs QT_QPA_EGLFS_HIDECURSOR=1 QT_ENABLE_HIGHDPI_SCALING=0 QT_SCALE_FACTOR=0.78125 ./build-pi/appNightStand
```

Logda şuna benzer bir satır çıkmalı:

```
Screen "..." logical size QSize(1024, 614) devicePixelRatio 0.78125
```

Kontrol listesi:

- [ ] Görüntü doğru yönde ve tüm ekranı kaplıyor
- [ ] Dokunulan yer doğru butonu tetikliyor
- [ ] İkonlar görünüyor
- [ ] Metin alanına dokununca sanal klavye açılıyor ve yazıyor
- [ ] Alarm sesi çalıyor
- [ ] Wi-Fi taranıyor ve bağlanıyor

`Ctrl+C` ile çık, masaüstünü geri aç:

```
sudo systemctl start lightdm
```

**Siyah ekran ya da "Could not find DRM device":** Pi 4/5'te birden fazla
`/dev/dri/card*` var ve eglfs ekran olmayanı seçmiş olabilir. `ls /dev/dri/`
çıktısıyla birlikte haber ver; servise doğru kartı gösteren bir ayar eklenecek.

## 5. Kalıcı kurulum

```
sudo raspi-config nonint do_boot_behaviour B1
sudo loginctl enable-linger nightstand
mkdir -p ~/.config/systemd/user
cp ~/NightStand/deploy/raspberrypi/nightstand.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable nightstand
```

- `B1`: Pi masaüstü yerine konsola açılır.
- `enable-linger`: servis ve ses (PipeWire) kimse giriş yapmadan başlar.
- `enable` (`--now` olmadan): masaüstü hâlâ açıkken başlatmaya çalışmaz,
  yeniden açılışta başlar.

Açılış yazılarını gizleyip konsolun kararmasını kapatmak için:

```
sudo cp /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.bak
sudo sed -i '1 s/$/ quiet logo.nologo vt.global_cursor_default=0 consoleblank=0/' /boot/firmware/cmdline.txt
cat /boot/firmware/cmdline.txt
```

`cmdline.txt` tek satır olmalı ve 3. adımdaki `video=DSI-1:...` hâlâ
içinde olmalı. Sonra:

```
sudo reboot
```

## Günlük kullanım

Windows'ta push ettikten sonra:

```
ssh nightstand ~/NightStand/deploy/raspberrypi/update.sh
```

| İş | Komut |
|---|---|
| Canlı log | `journalctl --user -u nightstand -f` |
| Durum | `systemctl --user status nightstand` |
| Durdur / başlat | `systemctl --user stop nightstand` / `start` |

## Masaüstüne geri dönmek

```
systemctl --user disable --now nightstand
sudo raspi-config nonint do_boot_behaviour B4
sudo reboot
```

3. adımdaki döndürme ayarları yerinde kalır. Masaüstünün `cmdline.txt`
döndürmesine uyup uymadığı test edilmedi; görüntü ile dokunmatik birbirini
tutmazsa 3. adımdaki geri alma komutlarını kullan.
