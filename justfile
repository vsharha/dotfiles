default:
    just --list

# Apply dotfiles (chezmoi, shared source in home/)
apply *args:
    ./apply.sh {{args}}

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
    ./linux/kde.sh

[linux]
gaming-pc:
    ./linux/hardware/gaming-pc-amd-7800x3d-rx9070xt.sh

[linux]
dualsense:
    ./linux/hardware/dualsense-ucm-fix.sh

[linux]
refind-theme:
    ./linux/boot/refind-theme-regular.sh
