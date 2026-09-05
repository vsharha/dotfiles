#!/usr/bin/env bash
set -euo pipefail

# `brew bundle dump` regenerates the Brewfile from scratch and drops every
# comment in it — the section headings, the notes on which entries are App
# Store builds, and the block of casks deliberately left commented out. Report
# the drift instead and edit the manifest by hand.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found." >&2
  exit 1
fi

DRIFT=false

# Anchored at the line start, so commented-out entries stay out of the listing.
listed() {
  sed -n "s/^$1 \"\([^\"]*\)\".*/\1/p" "$BREWFILE" | LC_ALL=C sort -u
}

report() {
  local heading="$1" body="$2"
  [ -n "$body" ] || return 0
  DRIFT=true
  printf '%s\n' "$heading"
  printf '%s\n\n' "$body" | sed 's/^./  &/'
}

formulae_installed="$(brew list --formula | LC_ALL=C sort -u)"
casks_installed="$(brew list --cask | LC_ALL=C sort -u)"

report "Installed on request, missing from the Brewfile:" \
  "$(comm -13 <(listed brew) <(brew leaves --installed-on-request | LC_ALL=C sort -u))"
report "Listed in the Brewfile, not installed:" \
  "$(comm -23 <(listed brew) <(printf '%s\n' "$formulae_installed"))"
report "Casks installed, missing from the Brewfile:" \
  "$(comm -13 <(listed cask) <(printf '%s\n' "$casks_installed"))"
report "Casks listed in the Brewfile, not installed:" \
  "$(comm -23 <(listed cask) <(printf '%s\n' "$casks_installed"))"

# mas entries carry the app id, so compare on that and print the names beside it.
if command -v mas >/dev/null 2>&1; then
  mas_installed="$(mas list || true)"
  name_for() {
    while IFS= read -r id; do
      [ -n "$id" ] || continue
      printf '%s\n' "$mas_installed" \
        | awk -v id="$id" '$1 == id { sub(/^[[:space:]]*[0-9]+[[:space:]]+/, ""); print; found = 1 }
                           END { if (!found) print id }'
    done
  }
  listed_ids="$(sed -n 's/^mas .*id: *\([0-9]*\).*/\1/p' "$BREWFILE" | LC_ALL=C sort -u)"
  installed_ids="$(printf '%s\n' "$mas_installed" | awk 'NF { print $1 }' | LC_ALL=C sort -u)"

  report "App Store apps installed, missing from the Brewfile:" \
    "$(comm -13 <(printf '%s\n' "$listed_ids") <(printf '%s\n' "$installed_ids") | name_for)"
  report "App Store apps listed in the Brewfile, not installed:" \
    "$(comm -23 <(printf '%s\n' "$listed_ids") <(printf '%s\n' "$installed_ids") | name_for)"
fi

if ! "$DRIFT"; then
  echo "Brewfile matches what is installed."
fi
