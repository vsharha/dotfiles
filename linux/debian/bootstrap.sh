#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
BIN_DIR="$HOME/.local/bin"
export PATH="$BIN_DIR:$PATH"

# Debian packages neither powerlevel10k nor fzf-tab and scatters the apt
# plugins across per-package dirs; clone the full set into one tree so the
# zshrc's single $_plugin_dir points at everything.
PLUGINS=(
  "powerlevel10k=https://github.com/romkatv/powerlevel10k"
  "fzf-tab=https://github.com/Aloxaf/fzf-tab"
  "zsh-autosuggestions=https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting=https://github.com/zsh-users/zsh-syntax-highlighting"
  "zsh-history-substring-search=https://github.com/zsh-users/zsh-history-substring-search"
)

install_apt_packages() {
  sudo apt-get update
  sed 's/#.*//' "$SCRIPT_DIR/packages.txt" | xargs -r sudo apt-get install -y
}

# Download completely before executing so a failed transfer stops bootstrap.
install_chezmoi() {
  command -v chezmoi >/dev/null 2>&1 && return 0
  local installer
  mkdir -p "$BIN_DIR"
  installer="$(curl --proto '=https' --proto-redir '=https' -fsLS https://get.chezmoi.io)"
  sh -c "$installer" -- -b "$BIN_DIR"
}

install_just() {
  command -v just >/dev/null 2>&1 && return 0
  local candidate installer
  candidate="$(LC_ALL=C apt-cache policy just | awk '/Candidate:/ { print $2 }')"
  if [ -n "$candidate" ] && [ "$candidate" != "(none)" ]; then
    sudo apt-get install -y just
  else
    mkdir -p "$BIN_DIR"
    installer="$(curl --proto '=https' --proto-redir '=https' -fsLS https://just.systems/install.sh)"
    bash -c "$installer" -- --to "$BIN_DIR"
  fi
}

install_zsh_plugins() {
  mkdir -p "$PLUGIN_DIR"
  local entry name url dest
  for entry in "${PLUGINS[@]}"; do
    name="${entry%%=*}"
    url="${entry#*=}"
    dest="$PLUGIN_DIR/$name"
    if [ -d "$dest/.git" ]; then
      git -C "$dest" pull --ff-only
    else
      git clone --depth 1 "$url" "$dest"
    fi
  done
}

set_login_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -n "$zsh_path" ] && [ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]; then
    sudo chsh -s "$zsh_path" "$USER"
  fi
}

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found; this bootstrap only supports Debian/Ubuntu." >&2
  exit 1
fi

install_apt_packages
install_chezmoi
install_just
install_zsh_plugins
set_login_shell

echo "Debian bootstrap complete."
