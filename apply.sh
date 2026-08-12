#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The Debian bootstrap installs chezmoi here, and a shell that started before
# the directory existed does not have it on PATH. Add it so the first apply
# after a bootstrap works without opening a new login shell.
export PATH="$HOME/.local/bin:$PATH"

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

# chezmoi init writes the config file that persists the headless role. Run it
# on first use, or whenever --headless is passed to switch the role.
CHEZMOI_CONFIG="$(chezmoi --source "$SCRIPT_DIR" execute-template '{{ .chezmoi.configFile }}')"

if [ "$HEADLESS" = true ]; then
  # --promptBool is keyed by the prompt text in home/.chezmoi.toml.tmpl, and
  # --prompt makes promptBoolOnce re-answer instead of reusing a stored value.
  chezmoi --source "$SCRIPT_DIR" --no-tty init \
    --prompt --promptBool "Headless server (no desktop)=true"
elif [ ! -f "$CHEZMOI_CONFIG" ]; then
  chezmoi --source "$SCRIPT_DIR" --no-tty init
fi

if [ "${#APPLY_ARGS[@]}" -eq 0 ]; then
  chezmoi --source "$SCRIPT_DIR" --no-tty apply
else
  chezmoi --source "$SCRIPT_DIR" --no-tty apply "${APPLY_ARGS[@]}"
fi
