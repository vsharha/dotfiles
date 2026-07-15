#!/usr/bin/env bash
set -euo pipefail

write_root_file() {
  local path="$1"

  sudo mkdir -p "$(dirname "$path")"
  sudo tee "$path" >/dev/null
}

write_root_file /etc/NetworkManager/conf.d/wifi-powersave-off.conf <<'EOF'
[connection]
wifi.powersave = 2
EOF

write_root_file /etc/modprobe.d/rtw89.conf <<'EOF'
options rtw89_core disable_ps_mode=1
options rtw89_pci disable_aspm_l1=1 disable_aspm_l1ss=1 disable_clkreq=1
EOF

echo "Gaming PC hardware config applied."
