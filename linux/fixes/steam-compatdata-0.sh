#!/usr/bin/env bash
set -euo pipefail

# Steam runs every Proton build in compatibilitytools.d against one shared
# prefix, compatdata/0, on each start
# (https://github.com/ValveSoftware/steam-for-linux/issues/8114). With two
# builds there, one build's wineboot can follow the other's DLL symlinks in
# that prefix and overwrite the other runner's files. Locking compatdata/0 makes
# those runs fail before Proton sets up a prefix. They never produce a usable
# shader-cache result for these builds anyway, so nothing is lost.

prefix="${XDG_DATA_HOME:-$HOME/.local/share}/Steam/steamapps/compatdata/0"

if pgrep -f 'ubuntu12_32/steam' >/dev/null; then
  echo "Close Steam first; it recreates compatdata/0 while running." >&2
  exit 1
fi

mkdir -p "$(dirname "$prefix")"

if [ -e "$prefix" ]; then
  sudo chattr -i "$prefix"
  chmod u+w "$prefix"
  rm -rf "$prefix"
fi

mkdir "$prefix"
chmod 555 "$prefix"
sudo chattr +i "$prefix"

echo "Steam's compatdata/0 prefix is locked."
