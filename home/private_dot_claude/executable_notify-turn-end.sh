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
# told apart. It does not name the session: ghostty shows the terminal title as
# the notification subtitle, and that already carries the session name.
title='Claude Code'
if [[ -n ${cwd:-} ]]; then
  title="$title · $(basename "$cwd")"
fi

# A semicolon ends the title field early and spills the rest into the body.
title="$(printf '%s' "$title" | tr -d '[:cntrl:];')"
title="${title:0:60}"

# Claude Code keeps the terminal title set to "<glyph> <session name>", where
# the glyph is ✳ at rest and alternates between ◐ and ◑ while a turn runs. The
# turn has not been marked finished by the time this hook runs, so the subtitle
# would show whichever spinner frame was current. Rewriting the title to the
# bare session name drops it; Claude Code sets its own title again on the next
# render. The name comes from the transcript's last ai-title record, which is
# the same string Claude Code puts in the title, so a session it has not named
# yet keeps the title it has.
session_title=''
if [[ -n ${transcript:-} && -f $transcript ]]; then
  session_title="$(grep -F '"type":"ai-title"' "$transcript" 2>/dev/null |
    tail -n 1 | jq -r '.aiTitle // empty' 2>/dev/null | tr -d '[:cntrl:]')" ||
    session_title=''
  session_title="${session_title:0:60}"
fi

set_title=''
if [[ -n $session_title ]]; then
  set_title=$'\033]0;'"$session_title"$'\033\\'
fi

# OSC 777 is the desktop-notification sequence ghostty honours when
# desktop-notifications is on (the default); ghostty drops it while the surface
# is focused, so only turns you are not watching notify. Terminals without
# support discard it, so this is a no-op rather than an error elsewhere. The
# title change is written in the same call so that Claude Code's own title
# update cannot land between the two sequences.
printf '%s\033]777;notify;%s;%s\033\\' "$set_title" "$title" "$body" >"/dev/$tty" 2>/dev/null || true
