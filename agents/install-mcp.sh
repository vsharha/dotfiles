#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Pinned so an install runs reviewed code; bump it deliberately.
INSTALLER="add-mcp@2.4.1"

for cmd in npx jq uvx; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found. Install it, then rerun this script." >&2
    exit 1
  fi
done

agent_args=(--agent claude-code --agent codex)
for agent in "$@"; do
  agent_args+=(--agent "$agent")
done

while IFS= read -r name <&3; do
  [ -n "$name" ] || continue

  source="$(jq -r --arg name "$name" '.mcpServers[$name]' "$SCRIPT_DIR/mcp.json")"
  source="${source/#\~/$HOME}"

  npx -y "$INSTALLER" "$source" \
    --name "$name" \
    --global \
    "${agent_args[@]}" \
    --yes
done 3< <(jq -r '.mcpServers | keys[]' "$SCRIPT_DIR/mcp.json")
