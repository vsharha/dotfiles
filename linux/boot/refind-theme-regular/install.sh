#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_REPO="https://github.com/bobafetthotmail/refind-theme-regular.git"
# The theme is copied into the EFI partition as root, so install a reviewed
# commit rather than whatever the default branch holds today.
THEME_COMMIT="ed76f1e6d1bfe790ea7333fe5886fa7af126475d"
THEME_NAME="refind-theme-regular"
INCLUDE_LINE="include themes/$THEME_NAME/theme.conf"
LEGACY_INCLUDE_LINE="include themes/regular-theme/theme.conf"
INCLUDE_COMMENT="# Load rEFInd theme Regular"
RESOLUTION_LINE="resolution max"
RESOLUTION_COMMENT="# Use the highest video mode the firmware reports"

path_is_dir() {
  local path="$1"

  [ -d "$path" ] || sudo test -d "$path"
}

path_is_file() {
  local path="$1"

  [ -f "$path" ] || sudo test -f "$path"
}

find_refind_dir() {
  local candidate

  if [ -n "${REFIND_DIR:-}" ]; then
    printf '%s\n' "$REFIND_DIR"
    return 0
  fi

  for candidate in /boot/efi/EFI/refind /boot/EFI/refind /efi/EFI/refind; do
    if path_is_dir "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

if ! command -v git >/dev/null 2>&1; then
  echo "git not found; install git before running this script." >&2
  exit 1
fi

REFIND_DIR="$(find_refind_dir)" || {
  echo "Could not find rEFInd. Set REFIND_DIR=/path/to/EFI/refind and rerun." >&2
  exit 1
}

if ! path_is_file "$REFIND_DIR/refind.conf"; then
  echo "refind.conf not found under $REFIND_DIR." >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
WORK_DIR="$TMP_DIR/$THEME_NAME"
git clone --quiet "$THEME_REPO" "$WORK_DIR"
git -C "$WORK_DIR" -c advice.detachedHead=false checkout --quiet "$THEME_COMMIT"

cd "$WORK_DIR"
cp "$SCRIPT_DIR/theme.conf" theme.conf

rm -rf src .git .devcontainer install.sh .gitignore

sudo rm -rf "$REFIND_DIR/regular-theme" "$REFIND_DIR/$THEME_NAME"
sudo rm -rf "$REFIND_DIR/themes/regular-theme" "$REFIND_DIR/themes/$THEME_NAME"
sudo mkdir -p "$REFIND_DIR/themes"
sudo cp -r "$WORK_DIR" "$REFIND_DIR/themes/$THEME_NAME"

sudo sed -i \
  -e "\|^$INCLUDE_COMMENT$|d" \
  -e "\|^$LEGACY_INCLUDE_LINE$|d" \
  -e "\|^$INCLUDE_LINE$|d" \
  -e "\|^$RESOLUTION_COMMENT$|d" \
  -e "\|^[[:space:]]*resolution[[:space:]]|d" \
  "$REFIND_DIR/refind.conf"

printf '\n%s\n%s\n%s\n%s\n' \
  "$RESOLUTION_COMMENT" "$RESOLUTION_LINE" \
  "$INCLUDE_COMMENT" "$INCLUDE_LINE" \
  | sudo tee -a "$REFIND_DIR/refind.conf" >/dev/null

echo "Installed rEFInd Regular theme: medium icons, dark theme, max resolution."
