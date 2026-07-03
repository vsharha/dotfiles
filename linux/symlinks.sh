#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "linux/symlinks.sh is deprecated; applying linux/chezmoi with chezmoi instead." >&2
exec "$SCRIPT_DIR/apply.sh" "$@"
