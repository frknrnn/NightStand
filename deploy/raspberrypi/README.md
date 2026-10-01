# Raspberry Pi kiosk kurulumu

NightStand'i masaüstü olmadan, açılışta doğrudan tam ekran çalıştırır
(Qt eglfs + systemd kullanıcı servisi). Arayüz 1024x600 için tasarlandı;
7" 800x480 panele `QT_SCALE_FACTOR=0.78125` ile ölçeklenir.

| Dosya | Ne işe yarar |
|---|---|
| `nightstand.service` | Uygulamayı eglfs ile başlatan, çökerse yeniden başlatan servis |
| `50-nightstand-networkmanager.rules` | Oturum yokken `nmcli` ile Wi-Fi bağlanma izni (polkit) |
| `update.sh` | `git pull` + derleme + servisi yeniden başlatma |

Tüm komutlar Pi'de, SSH oturumunda çalıştırılır. Kullanıcı adı `nightstand`,
proje `~/NightStand` altında, `build-pi` klasöründe derlenmiş olmalı.

## 1. Kontroller

```
ls /usr/lib/aarch64-linux-gnu/qt6/plugins/platforms/ | grep eglfs
ls /usr/lib/aarch64-linux-gnu/qt6/plugins/egldeviceintegrations/
groups
```

- İlk komut `libqeglfs.so` göstermeli.
- İkincisi `libqeglfs-kms-integration.so` içermeli.
- `groups` çıktısında `video`, `render` ve `input` olmalı (ekran ve dokunmatik erişimi).

## 2. Polkit kuralı

```
sudo cp ~/NightStand/deploy/raspberrypi/50-nightstand-networkmanager.rules /etc/polkit-1/rules.d/
```

## 3. Elle test (masaüstü geçici olarak kapalı)

Ekranı masaüstü tuttuğu sürece eglfs çizemez, önce onu durdur:

```
sudo systemctl stop lightdm
cd ~/NightStand
QT_QPA_PLATFORM=eglfs QT_QPA_EGLFS_HIDECURSOR=1 QT_ENABLE_HIGHDPI_SCALING=0 QT_SCALE_FACTOR=0.78125 ./build-pi/appNightStand
```

Logda şuna benzer bir satır çıkmalı:

```
Screen "..." logical size QSize(1024, 614) devicePixelRatio 0.78125
```

Dokunma, sanal klavye, alarm sesi ve Wi-Fi'yi dene. `Ctrl+C` ile çık,
masaüstünü geri aç:

```
sudo systemctl start lightdm
```

**Siyah ekran ya da "Could not find DRM device":** Pi 4/5'te birden fazla
`/dev/dri/card*` var ve eglfs ekran olmayanı seçmiş olabilir. `ls /dev/dri/`
çıktısıyla birlikte haber ver; servise doğru kartı gösteren bir ayar eklenecek.

## 4. Kalıcı kurulum

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

Açılış yazılarını gizleyip konsolun kararmasını kapatmak için (önce yedek al):

```
sudo cp /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.bak
sudo sed -i '1 s/$/ quiet logo.nologo vt.global_cursor_default=0 consoleblank=0/' /boot/firmware/cmdline.txt
cat /boot/firmware/cmdline.txt
```

`cmdline.txt` tek satır olmalı. Sonra:

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
