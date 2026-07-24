#!/usr/bin/env bash
set -euo pipefail

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  echo "kwriteconfig6 not found; skipping KDE config."
  exit 0
fi

configure_default_terminal() {
  if ! command -v ghostty >/dev/null 2>&1; then
    echo "Ghostty not found; keeping the current default terminal."
    return 0
  fi

  kwriteconfig6 \
    --file kdeglobals \
    --group General \
    --key TerminalApplication \
    ghostty
  kwriteconfig6 \
    --file kdeglobals \
    --group General \
    --key TerminalService \
    com.mitchellh.ghostty.desktop
}

configure_default_terminal

kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,ua,ru"
kwriteconfig6 --file kxkbrc --group Layout --key VariantList ",,"
kwriteconfig6 --file kxkbrc --group Layout --key DisplayNames ",,"

kwriteconfig6 \
  --file kglobalshortcutsrc \
  --group "KDE Keyboard Layout Switcher" \
  --key "Switch to Next Keyboard Layout" \
  "Alt+Shift,Meta+Alt+K,Switch to Next Keyboard Layout"

kwriteconfig6 --file ksmserverrc --group General --key loginMode emptySession

echo "KDE config applied."
