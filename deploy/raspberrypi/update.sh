#!/bin/sh
# Pull the latest code, rebuild and restart the kiosk.
#
# From Windows:  ssh nightstand ~/NightStand/deploy/raspberrypi/update.sh
set -e

cd "$HOME/NightStand"
git pull --ff-only

# First run on a fresh clone: configure once. Later builds re-run CMake on
# their own when CMakeLists.txt changes.
if [ ! -d build-pi ]; then
    cmake -S NightStand -B build-pi -G Ninja -DCMAKE_BUILD_TYPE=Release
fi
cmake --build build-pi -j4

# Keep the installed unit in step with the one in the repo.
install -Dm644 deploy/raspberrypi/nightstand.service \
    "$HOME/.config/systemd/user/nightstand.service"
systemctl --user daemon-reload

# Only restart once the kiosk is set up. Before that the desktop still owns
# the display and an eglfs instance would just fail and loop.
if systemctl --user is-enabled --quiet nightstand; then
    systemctl --user restart nightstand
    echo "NightStand updated and restarted."
else
    echo "NightStand built. Kiosk service not enabled, nothing restarted."
fi
