#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi not found. Install it first, then rerun this script." >&2
  exit 1
fi

chezmoi --source "$SCRIPT_DIR/home" apply "$@"

case "$(uname -s)" in
  Darwin) os_source="$SCRIPT_DIR/macos/home" ;;
  Linux)  os_source="$SCRIPT_DIR/linux/home" ;;
  *)      os_source="" ;;
esac

if [ -n "$os_source" ] && [ -d "$os_source" ]; then
  chezmoi --source "$os_source" apply "$@"
fi
