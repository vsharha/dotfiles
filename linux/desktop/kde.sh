#!/usr/bin/env bash
set -euo pipefail

# Without arguments the settings go to the current user's ~/.config. With
# --system they go to /etc/xdg, which KDE reads as defaults for every user:
# a key a user sets in their own ~/.config still overrides it. Shortcuts and
# window rules are the exception, and reach only accounts created afterwards;
# see kconfig.
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
  elif [ "$file" = kglobalshortcutsrc ] || [ "$file" = kwinrulesrc ]; then
    # kglobalacceld opens kglobalshortcutsrc without falling back to /etc/xdg,
    # and /etc/xdg/kwinrulesrc belongs to the kwin package, which replaces it
    # on upgrade. Both go to the template that useradd copies into new home
    # folders instead.
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

# kwin ships a "steam" rule in /etc/xdg/kwinrulesrc. Order lists the rules
# that apply, and the one written here replaces the shipped list, so it names
# steam as well.
keep_picture_in_picture_on_top() {
  kconfig kwinrulesrc \
    --group picture-in-picture \
    --key Description \
    "Picture-in-Picture always on top"
  kconfig kwinrulesrc --group picture-in-picture --key title Picture-in-picture
  kconfig kwinrulesrc --group picture-in-picture --key titlematch 2
  kconfig kwinrulesrc --group picture-in-picture --key above true
  kconfig kwinrulesrc --group picture-in-picture --key aboverule 2
  kconfig kwinrulesrc --group General --key Order steam,picture-in-picture
}

set_default_app() {
  local desktop_file="$1"
  shift

  if [ ! -e "/usr/share/applications/$desktop_file" ]; then
    echo "$desktop_file not found; keeping the current defaults for its types."
    return 0
  fi

  local mime_type
  for mime_type in "$@"; do
    kconfig mimeapps.list \
      --group "Default Applications" \
      --key "$mime_type" \
      "$desktop_file;"
  done
}

configure_default_apps() {
  set_default_app helium.desktop \
    text/html \
    x-scheme-handler/http \
    x-scheme-handler/https \
    x-scheme-handler/mailto
  set_default_app org.qbittorrent.qBittorrent.desktop \
    application/x-bittorrent \
    x-scheme-handler/magnet
  set_default_app vlc.desktop \
    audio/aac \
    audio/mp4 \
    audio/mpeg \
    audio/mpegurl \
    audio/ogg \
    audio/vnd.rn-realaudio \
    audio/vorbis \
    audio/x-flac \
    audio/x-mp3 \
    audio/x-mpegurl \
    audio/x-ms-wma \
    audio/x-musepack \
    audio/x-oggflac \
    audio/x-pn-realaudio \
    audio/x-scpls \
    audio/x-speex \
    audio/x-vorbis \
    audio/x-vorbis+ogg \
    audio/x-wav
}

# Breeze Dark stays the global theme; these override its window decoration,
# widget style, and sounds.
configure_theme() {
  kconfig kwinrc --group org.kde.kdecoration2 --key library org.kde.oxygen
  kconfig kwinrc --group org.kde.kdecoration2 --key theme Oxygen
  kconfig kdeglobals --group KDE --key widgetStyle Union
  kconfig kdeglobals --group Sounds --key Theme oxygen
}

configure_default_terminal
disable_floating_taskbar_panel
keep_picture_in_picture_on_top
configure_default_apps
configure_theme

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
