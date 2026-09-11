#!/usr/bin/env bash
set -euo pipefail

body="${1:-Turn finished}"

# Hooks are spawned without a controlling terminal, so /dev/tty is unavailable
# here. The parent process is claude itself, which does hold one.
tty="$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d '[:space:]')"
[[ -n $tty && $tty != '??' ]] || exit 0

# OSC 777 is the desktop-notification sequence ghostty honours when
# desktop-notifications is on (the default). Terminals without support discard
# it, so this is a no-op rather than an error elsewhere.
printf '\033]777;notify;Claude Code;%s\033\\' "$body" >"/dev/$tty" 2>/dev/null || true
