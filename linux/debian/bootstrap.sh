#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
BIN_DIR="$HOME/.local/bin"

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

# Install into ~/.local/bin (no sudo). The zshrc puts this on PATH for
# interactive shells; export it here so init_chezmoi finds the binary in this
# non-interactive bootstrap.
install_chezmoi() {
  export PATH="$BIN_DIR:$PATH"
  command -v chezmoi >/dev/null 2>&1 && return 0
  mkdir -p "$BIN_DIR"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
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
install_zsh_plugins
set_login_shell

echo "Debian bootstrap complete."
