#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# This script takes no arguments, and one silently ignored here is worse than a
# failure: the role flags belong on the apply step, which persists the answers
# through chezmoi init. Accepted and dropped, they install the desktop
# configuration on a server and report success.
if [ "$#" -gt 0 ]; then
  case " $* " in
    *" --headless "* | *" --dev "*)
      echo "role flags belong on the apply step: run 'just setup $*', or 'just apply $*' after this." >&2
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
