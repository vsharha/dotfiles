#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "chezmoi not found. Install it first, then rerun this script." >&2
  exit 1
fi

HEADLESS=false
APPLY_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --headless) HEADLESS=true ;;
    *) APPLY_ARGS+=("$arg") ;;
  esac
done

if [ "$HEADLESS" = true ]; then
  chezmoi --source "$SCRIPT_DIR" --no-tty init --promptBool headless=true
fi

if [ "${#APPLY_ARGS[@]}" -eq 0 ]; then
  chezmoi --source "$SCRIPT_DIR" --no-tty apply
else
  chezmoi --source "$SCRIPT_DIR" --no-tty apply "${APPLY_ARGS[@]}"
fi
