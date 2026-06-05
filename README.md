# dotfiles

## macOS

Install apps (Homebrew + App Store):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/bootstrap.sh)"
```

Then clone the repo and link configs into `~/.config`:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles && ~/dotfiles/macos/symlinks.sh
```

## Windows

Run this in PowerShell to set up a new PC:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/bootstrap.ps1 | iex
```
