#!/usr/bin/env bash
set -euo pipefail

sudo rm -f \
  /usr/share/alsa/ucm2/USB-Audio/Sony/DualSense-PS5.conf \
  /usr/share/alsa/ucm2/USB-Audio/Sony/DualSense-PS5-HiFi.conf

sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/dualsense-ucm.hook >/dev/null <<'EOF'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = alsa-ucm-conf

[Action]
Description = Removing broken DualSense UCM config
When = PostTransaction
Exec = /bin/rm -f /usr/share/alsa/ucm2/USB-Audio/Sony/DualSense-PS5.conf /usr/share/alsa/ucm2/USB-Audio/Sony/DualSense-PS5-HiFi.conf
EOF

echo "DualSense UCM files removed and pacman hook installed."
