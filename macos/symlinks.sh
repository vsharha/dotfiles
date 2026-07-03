#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "macos/symlinks.sh is deprecated; applying macos/chezmoi with chezmoi instead." >&2
exec "$SCRIPT_DIR/apply.sh" "$@"
