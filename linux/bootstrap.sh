#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# This script takes no arguments, and one silently ignored here is worse than a
# failure: --headless belongs on the apply step, which persists the role through
# chezmoi init. Accepted and dropped, it installs the desktop configuration on a
# server and reports success.
if [ "$#" -gt 0 ]; then
  case " $* " in
    *" --headless "*)
      echo "--headless belongs on the apply step: run 'just setup --headless', or 'just apply --headless' after this." >&2
      ;;
    *)
      echo "$(basename "$0") takes no arguments; got: $*" >&2
      ;;
  esac
  exit 2
fi

if grep -qi '^ID=.*cachyos' /etc/os-release 2>/dev/null; then
  "$SCRIPT_DIR/cachyos/bootstrap.sh"
  "$SCRIPT_DIR/desktop/kde.sh"
elif grep -qiE '^ID=(debian|ubuntu)' /etc/os-release 2>/dev/null \
  || grep -qi '^ID_LIKE=.*debian' /etc/os-release 2>/dev/null; then
  "$SCRIPT_DIR/debian/bootstrap.sh"
else
  echo "Unsupported Linux distro. Add a distro bootstrap under linux/ and update this script."
  exit 1
fi
