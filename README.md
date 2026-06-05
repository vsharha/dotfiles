# dotfiles

## macOS

Run this in Terminal to set up a new Mac:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/bootstrap.sh)"
```

## Windows

Run this in PowerShell to set up a new PC:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/bootstrap.ps1 | iex
```
