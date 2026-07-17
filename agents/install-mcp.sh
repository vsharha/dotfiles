#!/usr/bin/env bash
set -euo pipefail

# Install the MCP servers declared in mcp.json for Claude Code and Codex.
# Neither tool takes a config file we can own: Claude keeps servers in
# ~/.claude.json alongside its state, Codex in ~/.codex/config.toml. So drive
# their CLIs instead. Servers the apps manage themselves are left alone.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for cmd in claude codex jq uv; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found. Install it, then rerun this script." >&2
    exit 1
  fi
done

# Provides the notebooklm-mcp binary that mcp.json points at. Already-installed
# tools are left at their current version; upgrade with `uv tool upgrade`.
uv tool install notebooklm-mcp-cli

while IFS= read -r name; do
  [ -n "$name" ] || continue

  server="$(jq -c --arg name "$name" --arg home "$HOME" \
    '.mcpServers[$name] | .command |= sub("^~"; $home)' "$SCRIPT_DIR/mcp.json")"

  command_bin="$(jq -r '.command' <<<"$server")"
  args=()
  while IFS= read -r arg; do
    args+=("$arg")
  done < <(jq -r '.args[]?' <<<"$server")

  # Neither CLI overwrites an existing server, so drop it first.
  claude mcp remove "$name" -s user >/dev/null 2>&1 || true
  claude mcp add-json "$name" "$server" -s user >/dev/null

  codex mcp remove "$name" >/dev/null 2>&1 || true
  codex mcp add "$name" -- "$command_bin" ${args[@]+"${args[@]}"} >/dev/null

  echo "  $name"
done < <(jq -r '.mcpServers | keys[]' "$SCRIPT_DIR/mcp.json")
