#!/usr/bin/env bash
set -euo pipefail

FASTFETCH_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/config.jsonc"
if [ -z "${FASTFETCH_HOST_FORMAT+x}" ]; then
  FASTFETCH_HOST_FORMAT="Viktor's PC"
fi

write_root_file() {
  local path="$1"

  sudo mkdir -p "$(dirname "$path")"
  sudo tee "$path" >/dev/null
}

configure_fastfetch() {
  local tmp

  if ! command -v fastfetch >/dev/null 2>&1; then
    echo "fastfetch not found; install fastfetch before generating its config." >&2
    return 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "jq not found; install jq before generating the Fastfetch config." >&2
    return 1
  fi

  mkdir -p "$(dirname "$FASTFETCH_DEST")"
  tmp="$(mktemp)"
  fastfetch --gen-config-force "$tmp"

  jq --arg host "$FASTFETCH_HOST_FORMAT" '
    .modules |= map(
      if . == "host" then
        {"type": "host", "format": $host}
      elif type == "object" and .type == "host" then
        . + {"format": $host}
      else
        .
      end
    )
  ' "$tmp" > "$tmp.patched"

  if [ -f "$FASTFETCH_DEST" ] && cmp -s "$tmp.patched" "$FASTFETCH_DEST"; then
    rm -f "$tmp" "$tmp.patched"
    echo "ok     fastfetch/config.jsonc"
    return 0
  fi

  if [ -e "$FASTFETCH_DEST" ] || [ -L "$FASTFETCH_DEST" ]; then
    mv "$FASTFETCH_DEST" "$FASTFETCH_DEST.bak"
    echo "backup fastfetch/config.jsonc -> config.jsonc.bak"
  fi

  install -m 0644 "$tmp.patched" "$FASTFETCH_DEST"
  rm -f "$tmp" "$tmp.patched"
  echo "write  fastfetch/config.jsonc"
}

write_root_file /etc/NetworkManager/conf.d/wifi-powersave-off.conf <<'EOF'
[connection]
wifi.powersave = 2
EOF

write_root_file /etc/modprobe.d/rtw89.conf <<'EOF'
options rtw89_core disable_ps_mode=1
options rtw89_pci disable_aspm_l1=1 disable_aspm_l1ss=1 disable_clkreq=1
EOF

configure_fastfetch

echo "Gaming PC hardware config applied."
