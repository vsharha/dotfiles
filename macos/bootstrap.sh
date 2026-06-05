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

# Fetch the Brewfile and install everything
echo "Installing apps..."
BREWFILE="$(mktemp)"
curl -fsSL "https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/Brewfile" -o "$BREWFILE"
brew bundle install --file="$BREWFILE"
rm -f "$BREWFILE"

echo "Done."

# Remind about apps that must be installed by hand
echo
curl -fsSL "https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/MANUAL.md" 2>/dev/null || true
