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
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --headless) PROMPT_ARGS+=(--promptBool "Headless server (no desktop)=true") ;;
    --dev) PROMPT_ARGS+=(--promptBool "Development and agent configuration=true") ;;
    --dry-run|-n|--dry-run=true|-n=true)
      DRY_RUN=true
      APPLY_ARGS+=("$arg")
      ;;
    --dry-run=false|-n=false)
      DRY_RUN=false
      APPLY_ARGS+=("$arg")
      ;;
    -n*|-[^-]*n*)
      DRY_RUN=true
      APPLY_ARGS+=("$arg")
      ;;
    *) APPLY_ARGS+=("$arg") ;;
  esac
done

CHEZMOI_ARGS=(--source "$SCRIPT_DIR" --no-tty)
INIT_ARGS=()
if "$DRY_RUN"; then
  PREVIEW_DIR="$(mktemp -d)"
  trap 'rm -rf "$PREVIEW_DIR"' EXIT
  CHEZMOI_ARGS+=(--persistent-state "$PREVIEW_DIR/state.boltdb" --cache "$PREVIEW_DIR/cache")
  # Read saved answers from the normal config, but write preview answers only
  # to a temporary config that the following apply uses.
  INIT_ARGS+=(--config-path "$PREVIEW_DIR/chezmoi.toml")
fi

if [ "${#PROMPT_ARGS[@]}" -gt 0 ]; then
  INIT_ARGS+=(--prompt "${PROMPT_ARGS[@]}")
fi
# Bash 3.2 treats an empty array as unset under nounset.
chezmoi "${CHEZMOI_ARGS[@]}" init ${INIT_ARGS[@]+"${INIT_ARGS[@]}"}

if "$DRY_RUN"; then
  CHEZMOI_ARGS+=(--config "$PREVIEW_DIR/chezmoi.toml")
fi
chezmoi "${CHEZMOI_ARGS[@]}" apply ${APPLY_ARGS[@]+"${APPLY_ARGS[@]}"}
