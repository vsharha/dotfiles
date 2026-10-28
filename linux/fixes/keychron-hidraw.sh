#!/usr/bin/env bash
set -euo pipefail

# Let Chrome's WebHID reach the configuration interface (usage page 0xFF60) of
# the Keychron K4 HE and the Keychron Link dongle, so launcher.keychron.com can
# configure them. The keypress interfaces stay root-only, because any process
# that can open those can read every keystroke.
#
# The rule matches on the ENV keys set by usb_id in 60-persistent-hidraw.rules:
# idVendor and bInterfaceNumber live on different parent devices, and every
# ATTRS{} in one rule must match on the same parent. It must sort before
# 73-seat-late.rules, which applies the uaccess ACL only to devices already
# tagged.

sudo tee /etc/udev/rules.d/70-keychron.rules >/dev/null <<'EOF'
# K4 HE over cable
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ENV{ID_VENDOR_ID}=="3434", ENV{ID_MODEL_ID}=="0e41", ENV{ID_USB_INTERFACE_NUM}=="01", MODE="0660", TAG+="uaccess"
# Keychron Link dongle
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ENV{ID_VENDOR_ID}=="3434", ENV{ID_MODEL_ID}=="d030", ENV{ID_USB_INTERFACE_NUM}=="03", MODE="0660", TAG+="uaccess"
EOF

sudo udevadm control --reload-rules

echo "Keychron udev rule installed; replug the keyboard and dongle, then restart Chrome."
