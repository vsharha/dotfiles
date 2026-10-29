#!/usr/bin/env bash
set -euo pipefail

# PreToolUse hook that rejects a tool call whose input contains the signed-in
# account's email or a configured git email. Claude Code puts the account email
# into the model's context, and the model has sent it to third-party sites in
# curl User-Agent headers when a site asks API clients for a contact address.
#
# Exit status 2 blocks the call and hands stderr to the model as the reason.
# Any other failure, such as malformed input, lets the call through, so a bug
# here never wedges a session.

input="$(cat)"

cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"

# The account email is read on every call rather than stored in this repository,
# and the git email is read from the call's working directory so a
# repository-local override is covered as well as the global one.
emails=()
while IFS= read -r email; do
  [[ -n $email ]] && emails+=("$email")
done < <(
  jq -r '.oauthAccount.emailAddress // empty' "$HOME/.claude.json" 2>/dev/null || true
  git config --global user.email 2>/dev/null || true
  [[ -n $cwd && -d $cwd ]] && { git -C "$cwd" config user.email 2>/dev/null || true; }
)
((${#emails[@]})) || exit 0

# The whole tool input is searched as one JSON string, so a command, a URL, a
# header map or an MCP argument are all covered without knowing each tool's
# fields. Email addresses are case-insensitive, and a URL may carry the @ as
# %40, so both spellings are checked.
haystack="$(printf '%s' "$input" | jq -r '.tool_input | tojson | ascii_downcase')"

for email in "${emails[@]}"; do
  email="$(printf '%s' "$email" | tr '[:upper:]' '[:lower:]')"
  if [[ $haystack == *"$email"* || $haystack == *"${email/@/%40}"* ]]; then
    echo "Blocked: this call contains the user's email address. Do not send it to any service; use a neutral value such as a generic User-Agent instead, or ask the user." >&2
    exit 2
  fi
done
