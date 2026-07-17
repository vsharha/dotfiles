#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for cmd in npx jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found. Install it, then rerun this script." >&2
    exit 1
  fi
done

while IFS= read -r repo; do
  [ -n "$repo" ] || continue

  args=()
  while IFS= read -r skill; do
    args+=(--skill "$skill")
  done < <(jq -r --arg repo "$repo" '.skills[$repo][]' "$SCRIPT_DIR/skills.json")

  # With no --agent flags, the CLI installs to the agents it detects.
  npx -y skills@latest add "$repo" --global "${args[@]}" --yes
done < <(jq -r '.skills | keys[]' "$SCRIPT_DIR/skills.json")
