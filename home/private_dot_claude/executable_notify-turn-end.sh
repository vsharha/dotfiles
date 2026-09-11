#!/usr/bin/env bash
set -euo pipefail

# Hooks are spawned without a controlling terminal, so /dev/tty is unavailable
# here. The parent process is claude itself, which does hold one.
tty="$(ps -o tty= -p "$PPID" 2>/dev/null | tr -d '[:space:]')"
[[ -n $tty && $tty != '??' ]] || exit 0

log="${TMPDIR:-/tmp}/notify-turn-end.log"
input="$(cat)"

# Stop and StopFailure both pass last_assistant_message on stdin, so the
# transcript is not needed for the body. StopFailure also passes error — one of
# rate_limit, overloaded, invalid_request, model_not_found, server_error,
# max_output_tokens, cloud_credential_error, unknown — and, when the API
# returned one, error_details with the raw message. The kind leads: it is
# always present and it is the part that says whether waiting will help.
#
# The message is markdown. Backticks and emphasis markers are stripped because
# they render literally and spend characters that macOS only shows about three
# lines of. Control characters go too: an embedded newline or ESC would cut the
# escape sequence short. The result is capped on a word boundary, which keeps
# the sequence inside the terminal's OSC buffer, past which the whole
# notification is dropped rather than truncated.
if ! fields="$(printf '%s' "$input" | jq -r '
  (if .hook_event_name == "StopFailure"
   then "Failed: " + (.error // "unknown")
        + (if (.error_details // "") != "" then " — " + .error_details else "" end)
   else (.last_assistant_message // "")
   end
   | gsub("[[:cntrl:]]"; " ")
   | gsub("`|\\*\\*|__"; "")
   | gsub(" {2,}"; " ")
   | gsub("^ +| +$"; "")
   | if length > 160 then ((.[0:159] | sub(" [^ ]*$"; "")) + "…") else . end),
  (.cwd // ""),
  (.transcript_path // "")
' 2>/dev/null)"; then
  printf '%s unreadable payload: %.500s\n' "$(date -u +%FT%TZ)" "$input" >>"$log"
  fields=''
fi

{
  IFS= read -r body
  IFS= read -r cwd
  IFS= read -r transcript
} <<<"$fields" || true
body="${body:-Turn ended}"

# The title names the project, so notifications from different repositories are
# told apart. It names neither the application nor the session: the icon is
# ghostty's, and ghostty shows the terminal title as the notification subtitle,
# which carries the session name. Only a payload without cwd, which a Stop hook
# should not get, falls back to naming the application.
title='Claude Code'
if [[ -n ${cwd:-} ]]; then
  title="$(basename "$cwd")"
fi

# A semicolon ends the title field early and spills the rest into the body.
title="$(printf '%s' "$title" | tr -d '[:cntrl:];')"
title="${title:0:60}"

# Claude Code keeps the terminal title set to "<glyph> <session name>", where
# the glyph is ✳ at rest and alternates between ◐ and ◑ while a turn runs. The
# turn has not been marked finished by the time this hook runs, so the subtitle
# would show whichever spinner frame was current. Rewriting the title drops it;
# Claude Code sets its own title again on the next render.
#
# The name comes from the transcript: a custom-title record if the session has
# been renamed, otherwise the last ai-title. Claude Code prefers a rename over
# a generated name however late the name arrives, so the order here matches. A
# session that has neither, which means its first turn, falls back to the same
# default Claude Code uses. An empty title is not an option: ghostty then shows
# the working directory, which is longer and says less than the name it
# replaces.
session_title='Claude Code'
if [[ -n ${transcript:-} && -f $transcript ]]; then
  recorded="$(grep -F -e '"type":"custom-title"' -e '"type":"ai-title"' "$transcript" 2>/dev/null |
    jq -rs '(map(select(.type == "custom-title") | .customTitle) | last)
            // (map(select(.type == "ai-title") | .aiTitle) | last)
            // empty' 2>/dev/null | tr -d '[:cntrl:]')" || recorded=''
  if [[ -n $recorded ]]; then
    session_title="${recorded:0:60}"
  fi
fi

# Ghostty debounces terminal-title changes by 75ms before publishing the title
# the notification reads, so the two sequences cannot go out together: the
# notification would be built from the title this write is replacing. Waiting
# out the debounce with a margin for run-loop latency costs a sixth of a second
# at the end of a turn.
printf '\033]0;%s\033\\' "$session_title" >"/dev/$tty" 2>/dev/null || true
sleep 0.15

# OSC 777 is the desktop-notification sequence ghostty honours when
# desktop-notifications is on (the default); ghostty drops it while the surface
# is focused, so only turns you are not watching notify. Terminals without
# support discard it, so this is a no-op rather than an error elsewhere.
printf '\033]777;notify;%s;%s\033\\' "$title" "$body" >"/dev/$tty" 2>/dev/null || true
