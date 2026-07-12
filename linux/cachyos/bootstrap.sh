#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUR_HELPER="${AUR_HELPER:-paru}"

install_pacman_packages() {
  sed 's/#.*//' "$SCRIPT_DIR/packages.txt" | xargs -r sudo pacman -S --needed --noconfirm
}

install_aur_packages() {
  if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
    echo "AUR helper '$AUR_HELPER' not found. Install paru or set AUR_HELPER." >&2
    return 1
  fi

  sed 's/#.*//' "$SCRIPT_DIR/aur-packages.txt" | xargs -r "$AUR_HELPER" -S --needed --noconfirm
}

set_login_shell() {
  local zsh_path=/usr/bin/zsh

  if [ -x "$zsh_path" ] && [ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]; then
    sudo chsh -s "$zsh_path" "$USER"
  fi
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

add_user_to_gamemode_group() {
  if getent group gamemode >/dev/null 2>&1 && ! id -nG "$USER" | grep -qw gamemode; then
    sudo usermod -aG gamemode "$USER"
  fi
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

sudo pacman -Syu --noconfirm
install_pacman_packages
install_aur_packages
set_login_shell
add_user_to_gamemode_group
configure_snapper
enable_user_services

echo "CachyOS bootstrap complete."
