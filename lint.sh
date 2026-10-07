#!/usr/bin/env bash
set -euo pipefail

# Check the scripts and templates without touching the home directory.
#
# Every tracked sh and bash script goes through shellcheck at warning severity:
# below that it flags the `\033\\` string terminators in the OSC sequences as
# attempts to escape a quote. Templates are checked by rendering them for each
# machine role into an archive, which also runs the modify_ scripts, and the
# rendered zsh files then go through `zsh -n`. Only this OS's branches of the
# templates render, so a macOS-only mistake shows up only when linting on macOS.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

for cmd in shellcheck chezmoi zsh; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found. Install it, then rerun this script." >&2
    exit 1
  fi
done

failed=0

scripts=()
while IFS= read -r file; do
  case "$file" in *.tmpl) continue ;; esac
  if head -n 1 "$file" | grep -qE '^#!.*[/ ](ba)?sh$'; then
    scripts+=("$file")
  fi
done < <(git ls-files)

echo "shellcheck: ${#scripts[@]} scripts"
shellcheck --severity=warning "${scripts[@]}" || failed=1

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# headless dev personal, in the order of the README's four machines.
roles=(
  "desktop false true true"
  "server true false true"
  "sandbox true true true"
  "work false true false"
)
for role in "${roles[@]}"; do
  read -r name headless dev personal <<<"$role"
  dir="$WORK_DIR/$name"
  mkdir -p "$dir/home" "$dir/rendered"
  cat >"$dir/chezmoi.toml" <<EOF
[data]
    headless = $headless
    dev = $dev
    personal = $personal
    email = "lint@example.com"
[warnings]
    configFileTemplateHasChanged = false
EOF

  echo "chezmoi: $name"
  if ! chezmoi --source "$SCRIPT_DIR" --config "$dir/chezmoi.toml" \
    --destination "$dir/home" --persistent-state "$dir/state.boltdb" \
    --cache "$dir/cache" --no-tty \
    archive --format tar --output "$dir/home.tar"; then
    failed=1
    continue
  fi

  tar -xmf "$dir/home.tar" -C "$dir/rendered"
  for file in .zshrc .zshenv .zprofile; do
    [ -f "$dir/rendered/$file" ] || continue
    zsh -n "$dir/rendered/$file" || {
      echo "$name: $file does not parse" >&2
      failed=1
    }
  done
done

if [ "$failed" -ne 0 ]; then
  echo "lint failed." >&2
  exit 1
fi
echo "lint passed."
