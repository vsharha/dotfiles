#!/usr/bin/env bash
set -euo pipefail

# Make the kernel poll every interface of the Keychron Link dongle, even ones no
# process has open. Linux reads a HID interface only while something has it
# open, and desktops never open joysticks. Each Hall-effect profile switch on
# the K4 HE sends joystick reports on the dongle's joystick interface; when
# they go unread, the dongle stops delivering key reports until it is
# re-enumerated. Windows always polls, so it is unaffected.
#
# usbhid is built into the CachyOS kernel, so the quirk (0x400 is
# HID_QUIRK_ALWAYS_POLL) must be a kernel parameter; modprobe.d is ignored.

conf="${REFIND_LINUX_CONF:-/boot/refind_linux.conf}"
param="usbhid.quirks=0x3434:0xd030:0x00000400"

if ! sudo test -f "$conf"; then
  echo "$conf not found; set REFIND_LINUX_CONF to the rEFInd kernel options file." >&2
  exit 1
fi

if sudo grep -qF "$param" "$conf"; then
  echo "Keychron Link polling quirk already set in $conf."
  exit 0
fi

# The kernel keeps only the last usbhid.quirks= it is given, so a second one
# would silently drop the existing entries.
if sudo grep -q 'usbhid\.quirks=' "$conf"; then
  echo "$conf already sets usbhid.quirks; add 0x3434:0xd030:0x00000400 to that list by hand." >&2
  exit 1
fi

# Each boot entry is a line of two quoted fields: title, then kernel options.
sudo sed -i.bak "s/^\(\"[^\"]*\"[[:space:]]\+\"[^\"]*\)\"/\1 $param\"/" "$conf"

if sudo grep -E '^"' "$conf" | grep -qvF "$param"; then
  echo "Some entries in $conf were not updated; check it against $conf.bak." >&2
  exit 1
fi

echo "Keychron Link polling quirk added to $conf (backup at $conf.bak); reboot to apply."
