#!/usr/bin/env bash
set -euo pipefail

# Hooks are spawned without a controlling terminal, so /dev/tty is unavailable
# here. The parent process is claude itself, which does hold one.
tty="$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d '[:space:]')"
[[ -n $tty && $tty != '??' ]] || exit 0

# Stop and StopFailure both pass last_assistant_message on stdin, so the
# transcript never has to be parsed. StopFailure also names the failure kind
# (rate_limit, overloaded, server_error, ...), which is more use than the fact
# of a failure.
#
# The message is markdown and is sent as written, minus control characters: an
# embedded newline or ESC would cut the escape sequence short. The length cap
# keeps the sequence inside the terminal's OSC buffer, past which the whole
# notification is dropped rather than truncated.
body="$(jq -r '
  (if .hook_event_name == "StopFailure"
   then "Failed: " + (.error_details // .error)
   else (.last_assistant_message // "Turn finished")
   end)
  | gsub("[[:cntrl:]]"; " ")
  | gsub(" {2,}"; " ")
  | .[0:160]
  | gsub("^ +| +$"; "")
' 2>/dev/null)" || body=''
body="${body:-Turn ended}"

# OSC 777 is the desktop-notification sequence ghostty honours when
# desktop-notifications is on (the default). Terminals without support discard
# it, so this is a no-op rather than an error elsewhere.
printf '\033]777;notify;Claude Code;%s\033\\' "$body" >"/dev/$tty" 2>/dev/null || true
