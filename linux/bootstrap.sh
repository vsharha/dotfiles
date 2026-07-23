#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if grep -qi '^ID=.*cachyos' /etc/os-release 2>/dev/null; then
  "$SCRIPT_DIR/cachyos/bootstrap.sh"
  "$SCRIPT_DIR/desktop/kde.sh"
  exit 0
fi

if grep -qiE '^ID=(debian|ubuntu)' /etc/os-release 2>/dev/null \
  || grep -qi '^ID_LIKE=.*debian' /etc/os-release 2>/dev/null; then
  "$SCRIPT_DIR/debian/bootstrap.sh" "$@"
  exit 0
fi

echo "Unsupported Linux distro. Add a distro bootstrap under linux/ and update this script."
exit 1
