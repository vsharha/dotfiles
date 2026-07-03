#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACMAN_PACKAGES_FILE="$SCRIPT_DIR/packages.txt"
AUR_PACKAGES_FILE="$SCRIPT_DIR/aur-packages.txt"
AUR_HELPER="${AUR_HELPER:-paru}"

load_packages() {
  local file="$1"
  local -n out="$2"
  local line

  [ -f "$file" ] || return 0

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -n "$line" ] && out+=("$line")
  done < "$file"
}

install_pacman_packages() {
  local packages=()
  load_packages "$PACMAN_PACKAGES_FILE" packages

  if [ "${#packages[@]}" -eq 0 ]; then
    echo "No pacman packages listed."
    return 0
  fi

  sudo pacman -S --needed --noconfirm "${packages[@]}"
}

upgrade_system() {
  sudo pacman -Syu --noconfirm
}

install_aur_packages() {
  local packages=()
  load_packages "$AUR_PACKAGES_FILE" packages

  if [ "${#packages[@]}" -eq 0 ]; then
    echo "No AUR packages listed."
    return 0
  fi

  if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
    echo "AUR helper '$AUR_HELPER' not found. Install paru or set AUR_HELPER." >&2
    return 1
  fi

  "$AUR_HELPER" -S --needed --noconfirm "${packages[@]}"
}

configure_snapper() {
  local root_fstype
  root_fstype="$(findmnt -n -o FSTYPE / 2>/dev/null || true)"

  if [ "$root_fstype" != "btrfs" ] || ! command -v snapper >/dev/null 2>&1; then
    echo "Snapper not configured; root is not Btrfs or snapper is unavailable."
    return 0
  fi

  sudo snapper -c root create-config / 2>/dev/null || true
  sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
}

enable_user_services() {
  if ! command -v syncthing >/dev/null 2>&1; then
    return 0
  fi

  systemctl --user enable syncthing.service || {
    echo "Could not enable syncthing.service for this user session." >&2
    return 0
  }
}

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found; this bootstrap only supports CachyOS." >&2
  exit 1
fi

upgrade_system
install_pacman_packages
install_aur_packages
configure_snapper
enable_user_services

echo "CachyOS bootstrap complete."
