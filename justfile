default:
    just --list

# Apply shared and OS-specific dotfiles with chezmoi
apply *args:
    ./apply.sh {{ args }}

# Install agent skills for Claude Code and any additional agents
skills *agents:
    ./agents/install-skills.sh {{ agents }}

# Install MCP servers for Claude Code, Codex, and any additional agents
mcp *agents:
    ./agents/install-mcp.sh {{ agents }}

# Install apps and CLI tools with Homebrew
[macos]
bootstrap *args:
    ./macos/bootstrap.sh {{ args }}

# Install packages and set zsh as the login shell. Pass --headless on a
# Debian/Ubuntu server to persist the headless role (drops desktop-only configs).
[linux]
bootstrap *args:
    ./linux/bootstrap.sh {{ args }}

# Bootstrap this OS, then apply dotfiles. Pass --headless through to bootstrap.
setup *args: (bootstrap args) apply

[linux]
kde:
    ./linux/desktop/kde.sh

[linux]
gaming-pc:
    ./linux/profiles/gaming-pc.sh

[linux]
dualsense:
    ./linux/fixes/dualsense-ucm.sh

[linux]
refind-theme:
    ./linux/boot/refind-theme-regular/install.sh
