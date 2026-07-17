#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for cmd in npx jq uv; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found. Install it, then rerun this script." >&2
    exit 1
  fi
done

# Provides the notebooklm-mcp binary that mcp.json points at. Already-installed
# tools are left at their current version; upgrade with `uv tool upgrade`.
uv tool install notebooklm-mcp-cli >/dev/null

while IFS= read -r name; do
  [ -n "$name" ] || continue

  source="$(jq -r --arg name "$name" '.mcpServers[$name]' "$SCRIPT_DIR/mcp.json")"
  source="${source/#\~/$HOME}"

  # With no --agent flags, the CLI installs to the agents it detects.
  npx -y add-mcp@latest "$source" --name "$name" --global --yes
done < <(jq -r '.mcpServers | keys[]' "$SCRIPT_DIR/mcp.json")
