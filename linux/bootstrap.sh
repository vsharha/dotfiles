#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f /etc/arch-release ] || grep -qi '^ID=.*cachyos\|^ID_LIKE=.*arch' /etc/os-release 2>/dev/null; then
  "$SCRIPT_DIR/arch/bootstrap.sh"
  exit 0
fi

echo "Unsupported Linux distro. Add a distro bootstrap under linux/ and update this script."
exit 1

