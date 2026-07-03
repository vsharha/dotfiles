#!/usr/bin/env bash
set -euo pipefail

THEME_REPO="https://github.com/bobafetthotmail/refind-theme-regular.git"
THEME_NAME="refind-theme-regular"
INCLUDE_LINE="include themes/$THEME_NAME/theme.conf"
LEGACY_INCLUDE_LINE="include themes/regular-theme/theme.conf"
INCLUDE_COMMENT="# Load rEFInd theme Regular"

find_refind_dir() {
  local candidate

  if [ -n "${REFIND_DIR:-}" ]; then
    printf '%s\n' "$REFIND_DIR"
    return 0
  fi

  for candidate in /boot/efi/EFI/refind /boot/EFI/refind /efi/EFI/refind; do
    if [ -d "$candidate" ]; then
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

if [ ! -f "$REFIND_DIR/refind.conf" ]; then
  echo "refind.conf not found under $REFIND_DIR." >&2
  exit 1
fi

WORK_DIR="/tmp/$THEME_NAME"
rm -rf "$WORK_DIR"
git clone "$THEME_REPO" "$WORK_DIR"

cd "$WORK_DIR"
cp src/theme.conf theme.conf
sed -i \
  -e "s/#icons_dir themes\/$THEME_NAME\/icons\/256-96/icons_dir themes\/$THEME_NAME\/icons\/256-96/" \
  -e "s/#big_icon_size 256/big_icon_size 256/" \
  -e "s/#small_icon_size 96/small_icon_size 96/" \
  -e "s/#banner themes\/$THEME_NAME\/icons\/256-96\/bg_dark.png/banner themes\/$THEME_NAME\/icons\/256-96\/bg_dark.png/" \
  -e "s/#selection_big themes\/$THEME_NAME\/icons\/256-96\/selection_dark-big.png/selection_big themes\/$THEME_NAME\/icons\/256-96\/selection_dark-big.png/" \
  -e "s/#selection_small themes\/$THEME_NAME\/icons\/256-96\/selection_dark-small.png/selection_small themes\/$THEME_NAME\/icons\/256-96\/selection_dark-small.png/" \
  theme.conf

rm -rf src .git .devcontainer install.sh .gitignore

sudo rm -rf "$REFIND_DIR/regular-theme" "$REFIND_DIR/$THEME_NAME"
sudo rm -rf "$REFIND_DIR/themes/regular-theme" "$REFIND_DIR/themes/$THEME_NAME"
sudo mkdir -p "$REFIND_DIR/themes"
sudo cp -r "$WORK_DIR" "$REFIND_DIR/themes/$THEME_NAME"

sudo sed -i \
  -e "\|^$INCLUDE_COMMENT$|d" \
  -e "\|^$LEGACY_INCLUDE_LINE$|d" \
  -e "\|^$INCLUDE_LINE$|d" \
  "$REFIND_DIR/refind.conf"

printf '\n%s\n%s\n' "$INCLUDE_COMMENT" "$INCLUDE_LINE" | sudo tee -a "$REFIND_DIR/refind.conf" >/dev/null

echo "Installed rEFInd Regular theme: medium icons, dark theme."
