#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HEADLESS=false

for arg in "$@"; do
  case "$arg" in
    --headless) HEADLESS=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

init_chezmoi() {
  if [ "$HEADLESS" = true ]; then
    chezmoi --no-tty init --source "$REPO_ROOT" --promptBool headless=true
  else
    chezmoi --no-tty init --source "$REPO_ROOT"
  fi
}

if grep -qi '^ID=.*cachyos' /etc/os-release 2>/dev/null; then
  if [ "$HEADLESS" = true ]; then
    echo "--headless is only supported on Debian/Ubuntu." >&2
    exit 1
  fi

  "$SCRIPT_DIR/cachyos/bootstrap.sh"
  "$SCRIPT_DIR/desktop/kde.sh"
elif grep -qiE '^ID=(debian|ubuntu)' /etc/os-release 2>/dev/null \
  || grep -qi '^ID_LIKE=.*debian' /etc/os-release 2>/dev/null; then
  "$SCRIPT_DIR/debian/bootstrap.sh"
else
  echo "Unsupported Linux distro. Add a distro bootstrap under linux/ and update this script."
  exit 1
fi

echo "Initializing chezmoi..."
init_chezmoi
