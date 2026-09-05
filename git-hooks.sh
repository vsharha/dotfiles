#!/usr/bin/env bash
set -euo pipefail

# Install the Git hook template into repositories that already exist.
#
# git init and git clone copy init.templateDir into every repository made from
# now on, so this pass is needed once for the ones cloned before the template
# existed. Reinitializing adds only the hooks a repository is missing and
# leaves its own hooks, branch, worktree, and history alone.

TEMPLATE="$(git config --path --get init.templateDir || true)"
if [ -z "$TEMPLATE" ] || [ ! -d "$TEMPLATE/hooks" ]; then
  echo "init.templateDir names no directory with hooks. Run 'just apply' first." >&2
  exit 1
fi

HOOKS=()
for hook in "$TEMPLATE"/hooks/*; do
  [ -f "$hook" ] || continue
  HOOKS+=("$(basename "$hook")")
done
if [ "${#HOOKS[@]}" -eq 0 ]; then
  echo "$TEMPLATE/hooks is empty; nothing to install." >&2
  exit 1
fi

ROOTS=("$@")
if [ "${#ROOTS[@]}" -eq 0 ]; then
  ROOTS=("$HOME/Projects")
fi
for root in "${ROOTS[@]}"; do
  if [ ! -d "$root" ]; then
    echo "$root is not a directory." >&2
    exit 1
  fi
done

installed=0
complete=0
failed=0

# -prune keeps find out of the repositories themselves. A .git file rather
# than a directory marks a submodule or linked worktree, whose hooks live in
# the repository it points at, so those are skipped.
while IFS= read -r gitdir; do
  repo="$(dirname "$gitdir")"

  missing=()
  for name in "${HOOKS[@]}"; do
    [ -e "$gitdir/hooks/$name" ] || missing+=("$name")
  done
  if [ "${#missing[@]}" -eq 0 ]; then
    complete=$((complete + 1))
    continue
  fi

  if git init --quiet --template="$TEMPLATE" "$repo" >/dev/null; then
    echo "$repo: ${missing[*]}"
    installed=$((installed + 1))
  else
    echo "$repo: git init failed" >&2
    failed=$((failed + 1))
  fi
done < <(find "${ROOTS[@]}" -type d -name .git -prune | sort)

echo "$installed updated, $complete already complete, $failed failed."
[ "$failed" -eq 0 ]
