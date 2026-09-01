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

# --promptBool is keyed by the prompt text in home/.chezmoi.toml.tmpl, not by
# the data key. Each flag answers one axis; an axis no flag names is asked for.
PROMPT_ARGS=()
APPLY_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --headless) PROMPT_ARGS+=(--promptBool "Headless server (no desktop)=true") ;;
    --dev) PROMPT_ARGS+=(--promptBool "Development and agent configuration=true") ;;
    *) APPLY_ARGS+=("$arg") ;;
  esac
done

# chezmoi init writes the config file that persists the machine's role. It runs
# on every apply, not only the first: promptBoolOnce reuses a stored answer, so
# a machine that has answered is never asked again, while a config file written
# before an axis existed gains the missing key on the next run.
#
# --prompt is what makes a stored answer re-asked, so a role flag can only
# change a value when it is passed. It applies to every prompt rather than the
# one a --promptBool names, which is why an unnamed axis is asked interactively
# instead of keeping its current value. Pass both flags to answer both.
if [ "${#PROMPT_ARGS[@]}" -gt 0 ]; then
  chezmoi --source "$SCRIPT_DIR" --no-tty init --prompt "${PROMPT_ARGS[@]}"
else
  chezmoi --source "$SCRIPT_DIR" --no-tty init
fi

if [ "${#APPLY_ARGS[@]}" -eq 0 ]; then
  chezmoi --source "$SCRIPT_DIR" --no-tty apply
else
  chezmoi --source "$SCRIPT_DIR" --no-tty apply "${APPLY_ARGS[@]}"
fi
