default:
    just --list

# Apply shared and OS-specific dotfiles with chezmoi
apply *args:
    ./apply.sh {{args}}

# Install agent skills for Claude Code and Codex
skills:
    ./agents/install-skills.sh

# Install MCP servers for Claude Code and Codex
mcp:
    ./agents/install-mcp.sh

# Install apps and CLI tools with Homebrew
[macos]
bootstrap:
    ./macos/bootstrap.sh

# Install packages and set zsh as the login shell (CachyOS)
[linux]
bootstrap:
    ./linux/bootstrap.sh

# Bootstrap this OS, then apply dotfiles
setup: bootstrap apply

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
