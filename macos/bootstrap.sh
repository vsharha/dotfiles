#!/usr/bin/env bash
set -euo pipefail

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Load brew into the current shell (Apple Silicon, then Intel fallback)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Use the local repo files when run from a checkout; fall back to fetching
# from GitHub for the curl-pipe first-run case (no repo cloned yet).
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

echo "Installing apps..."
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/Brewfile" ]; then
  brew bundle install --file="$SCRIPT_DIR/Brewfile"
else
  BREWFILE="$(mktemp)"
  curl -fsSL "https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/Brewfile" -o "$BREWFILE"
  brew bundle install --file="$BREWFILE"
  rm -f "$BREWFILE"
fi

echo "Done."

# Remind about apps that must be installed by hand
echo
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/MANUAL.md" ]; then
  cat "$SCRIPT_DIR/MANUAL.md"
else
  curl -fsSL "https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/MANUAL.md" 2>/dev/null || true
fi
