#!/usr/bin/env bash
set -euo pipefail

# Without arguments the settings go to the current user's ~/.config. With
# --system they go to /etc/xdg, which KDE reads as defaults for every user:
# a key a user sets in their own ~/.config still overrides it. Shortcuts are
# the exception, and reach only accounts created afterwards; see kconfig.
system=false
case "${1-}" in
  "") ;;
  --system) system=true ;;
  *)
    echo "usage: $(basename "$0") [--system]" >&2
    exit 2
    ;;
esac

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  echo "kwriteconfig6 not found; skipping KDE config."
  exit 0
fi

kconfig() {
  local file="$1"
  shift
  if [ "$system" = false ]; then
    kwriteconfig6 --file "$file" "$@"
  elif [ "$file" = kglobalshortcutsrc ]; then
    # kglobalacceld opens this file without falling back to /etc/xdg, so the
    # shortcuts go to the template that useradd copies into new home folders.
    sudo kwriteconfig6 --file "/etc/skel/.config/$file" "$@"
  else
    sudo kwriteconfig6 --file "/etc/xdg/$file" "$@"
  fi
}

configure_default_terminal() {
  if ! command -v ghostty >/dev/null 2>&1; then
    echo "Ghostty not found; keeping the current default terminal."
    return 0
  fi

  kconfig kdeglobals \
    --group General \
    --key TerminalApplication \
    ghostty
  kconfig kdeglobals \
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

  if [ "$system" = true ]; then
    # Plasma runs each script in this directory once per user, when their
    # desktop next starts, and records it in plasmashellrc so it never reruns.
    # The name only needs to stay clear of the scripts plasma-desktop ships.
    printf '%s' "$plasma_script" | sudo tee \
      /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/dotfiles_taskbar_not_floating.js \
      >/dev/null
    return 0
  fi

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

kconfig kwinrc --group ElectricBorders --key TopRight None
kconfig kwinrc --group TabBox --key LayoutName thumbnail_grid

kconfig kscreenlockerrc --group Daemon --key Autolock false
kconfig kscreenlockerrc --group Daemon --key Timeout 0

kconfig powerdevilrc \
  --group AC \
  --group Display \
  --key DimDisplayWhenIdle \
  true
kconfig powerdevilrc \
  --group AC \
  --group Display \
  --key DimDisplayIdleTimeoutSec \
  300
kconfig powerdevilrc \
  --group AC \
  --group Display \
  --key TurnOffDisplayWhenIdle \
  false
kconfig powerdevilrc \
  --group AC \
  --group Display \
  --key TurnOffDisplayIdleTimeoutSec \
  -- \
  -1
kconfig powerdevilrc \
  --group AC \
  --group SuspendAndShutdown \
  --key AutoSuspendAction \
  0

kconfig plasmaparc --group General --key AudioFeedback false
kconfig kcminputrc --group Keyboard --key NumLock 0

kconfig kxkbrc --group Layout --key Use true
kconfig kxkbrc --group Layout --key LayoutList "us,ua,ru"
kconfig kxkbrc --group Layout --key VariantList ",,"
kconfig kxkbrc --group Layout --key DisplayNames ",,"

kconfig kglobalshortcutsrc \
  --group "KDE Keyboard Layout Switcher" \
  --key "Switch to Next Keyboard Layout" \
  "Alt+Shift,Meta+Alt+K,Switch to Next Keyboard Layout"

kconfig ksmserverrc --group General --key loginMode emptySession

kconfig krunnerrc --group General --key FreeFloating true

if [ "$system" = true ]; then
  echo "KDE defaults applied for all users."
else
  echo "KDE config applied."
fi
