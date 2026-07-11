#!/usr/bin/env bash
set -euo pipefail

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  echo "kwriteconfig6 not found; skipping KDE config."
  exit 0
fi

kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,ua,ru"
kwriteconfig6 --file kxkbrc --group Layout --key VariantList ",,"
kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames ",,"

kwriteconfig6 \
  --file kglobalshortcutsrc \
  --group "KDE Keyboard Layout Switcher" \
  --key "Switch to Next Keyboard Layout" \
  "Alt+Shift,Meta+Alt+K,Switch to Next Keyboard Layout"

kwriteconfig6 --file ksmserverrc --group General --key loginMode restoreSavedSession

# Adaptive Sync is configured per output and is available in Plasma Wayland.
if [[ ${XDG_SESSION_TYPE:-} == wayland ]] && command -v kscreen-doctor >/dev/null 2>&1; then
  mapfile -t vrr_outputs < <(
    kscreen-doctor --outputs | awk '
      /^Output:/ { output = $2 }
      /^Vrr: capable$/ { print output }
    '
  )

  for output in "${vrr_outputs[@]}"; do
    kscreen-doctor "output.${output}.vrrpolicy.automatic"
  done
fi

echo "KDE config applied."
