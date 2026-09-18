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

# --promptBool and --promptString are keyed by the prompt text in
# home/.chezmoi.toml.tmpl, not by the data key. Each flag answers one prompt;
# what becomes of the prompts left unnamed depends on --prompt, added below
# whenever any flag is present.
PROMPT_ARGS=()
APPLY_ARGS=()
DRY_RUN=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --headless) PROMPT_ARGS+=(--promptBool "Headless server (no desktop)=true") ;;
    --no-headless) PROMPT_ARGS+=(--promptBool "Headless server (no desktop)=false") ;;
    --dev) PROMPT_ARGS+=(--promptBool "Development and agent configuration=true") ;;
    --no-dev) PROMPT_ARGS+=(--promptBool "Development and agent configuration=false") ;;
    --personal) PROMPT_ARGS+=(--promptBool "Personal accounts and services=true") ;;
    --no-personal) PROMPT_ARGS+=(--promptBool "Personal accounts and services=false") ;;
    # The Git email is the one answer no role implies, so it needs a value
    # rather than a direction. Without it an apply that passes any flag stops
    # to ask, which --no-tty below turns into a read from stdin.
    --email)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "--email needs an address, e.g. --email you@example.com" >&2
        exit 1
      fi
      PROMPT_ARGS+=(--promptString "Git email=$2")
      shift
      ;;
    --email=*)
      if [ -z "${1#--email=}" ]; then
        echo "--email needs an address, e.g. --email=you@example.com" >&2
        exit 1
      fi
      PROMPT_ARGS+=(--promptString "Git email=${1#--email=}")
      ;;
    --dry-run|-n|--dry-run=true|-n=true)
      DRY_RUN=true
      APPLY_ARGS+=("$1")
      ;;
    --dry-run=false|-n=false)
      DRY_RUN=false
      APPLY_ARGS+=("$1")
      ;;
    -n*|-[^-]*n*)
      DRY_RUN=true
      APPLY_ARGS+=("$1")
      ;;
    *) APPLY_ARGS+=("$1") ;;
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

# --prompt is what lets a flag override an answer already saved for its prompt:
# the prompt*Once functions read --promptBool and --promptString only when they
# would prompt. It also re-asks whatever no flag named, defaulting to the saved
# answer, so an apply that passes one flag should pass the rest too when nothing
# can answer the re-asked prompts.
if [ "${#PROMPT_ARGS[@]}" -gt 0 ]; then
  INIT_ARGS+=(--prompt "${PROMPT_ARGS[@]}")
fi
# Bash 3.2 treats an empty array as unset under nounset.
chezmoi "${CHEZMOI_ARGS[@]}" init ${INIT_ARGS[@]+"${INIT_ARGS[@]}"}

if "$DRY_RUN"; then
  CHEZMOI_ARGS+=(--config "$PREVIEW_DIR/chezmoi.toml")
fi
chezmoi "${CHEZMOI_ARGS[@]}" apply ${APPLY_ARGS[@]+"${APPLY_ARGS[@]}"}
