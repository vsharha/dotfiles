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

disable_floating_taskbar_panel() {
  local plasma_script='
panels().forEach(function (panel) {
  panel.widgets().forEach(function (widget) {
    if (widget.type === "org.kde.plasma.taskmanager"
        || widget.type === "org.kde.plasma.icontasks") {
      panel.floating = false;
    }
  });
});
'
  local qdbus_command

  if command -v qdbus6 >/dev/null 2>&1; then
    qdbus_command=qdbus6
  elif command -v qdbus >/dev/null 2>&1; then
    qdbus_command=qdbus
  else
    echo "qdbus not found; skipping KDE taskbar panel config."
    return 0
  fi

  if ! "$qdbus_command" \
    org.kde.plasmashell \
    /PlasmaShell \
    org.kde.PlasmaShell.evaluateScript \
    "$plasma_script"; then
    echo "Could not reach Plasma Shell; skipping KDE taskbar panel config."
  fi
}

configure_default_terminal
disable_floating_taskbar_panel

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

kwriteconfig6 --file krunnerrc --group General --key FreeFloating true

echo "KDE config applied."
