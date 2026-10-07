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

# Each role flag exports the variable .chezmoi.toml.tmpl reads in place of the
# saved answer for that axis. Axes no flag names keep their saved answers.
APPLY_ARGS=()
DRY_RUN=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --headless) export DOTFILES_HEADLESS=true ;;
    --no-headless) export DOTFILES_HEADLESS=false ;;
    --dev) export DOTFILES_DEV=true ;;
    --no-dev) export DOTFILES_DEV=false ;;
    --personal) export DOTFILES_PERSONAL=true ;;
    --no-personal) export DOTFILES_PERSONAL=false ;;
    --email)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "--email needs an address, e.g. --email you@example.com" >&2
        exit 1
      fi
      export DOTFILES_EMAIL="$2"
      shift
      ;;
    --email=*)
      if [ -z "${1#--email=}" ]; then
        echo "--email needs an address, e.g. --email=you@example.com" >&2
        exit 1
      fi
      export DOTFILES_EMAIL="${1#--email=}"
      ;;
    --dry-run|-n|--dry-run=true|-n=true)
      DRY_RUN=true
      APPLY_ARGS+=("$1")
      ;;
    --dry-run=false|-n=false)
      DRY_RUN=false
      APPLY_ARGS+=("$1")
      ;;
    *)
      # A cluster of chezmoi's argument-free short flags that includes -n,
      # such as -nv. Flags that take a value are left out, so -xencrypted is
      # not mistaken for one.
      if [[ $1 =~ ^-[hPrkv]*n[hPrkv]*$ ]]; then
        DRY_RUN=true
      fi
      APPLY_ARGS+=("$1")
      ;;
  esac
  shift
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

# Bash 3.2 treats an empty array as unset under nounset.
chezmoi "${CHEZMOI_ARGS[@]}" init ${INIT_ARGS[@]+"${INIT_ARGS[@]}"}

if "$DRY_RUN"; then
  CHEZMOI_ARGS+=(--config "$PREVIEW_DIR/chezmoi.toml")
fi
chezmoi "${CHEZMOI_ARGS[@]}" apply ${APPLY_ARGS[@]+"${APPLY_ARGS[@]}"}
