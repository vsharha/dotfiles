#!/usr/bin/env bash
set -euo pipefail

# Symlink recorded Linux configs into ~/.config and home files into $HOME.
# Existing files/dirs are backed up to <name>.bak before linking.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_tree() {
  local src_dir="$1" dest_dir="$2"
  [ -d "$src_dir" ] || return 0

  find "$src_dir" -type f -print0 | while IFS= read -r -d '' src; do
    local rel="${src#"$src_dir"/}"
    local dest="$dest_dir/$rel"

    mkdir -p "$(dirname "$dest")"

    if [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then
      echo "ok     $rel"
      continue
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
      mv "$dest" "$dest.bak"
      echo "backup $rel -> $rel.bak"
    fi

    ln -s "$src" "$dest"
    echo "link   $rel"
  done
}

link_tree "$SCRIPT_DIR/config" "${XDG_CONFIG_HOME:-$HOME/.config}"
link_tree "$SCRIPT_DIR/home" "$HOME"

echo "Done."

