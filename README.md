# dotfiles

Platform setup scripts install apps and tools. Dotfiles are managed with
platform-specific chezmoi source directories:

- `macos/chezmoi`
- `linux/chezmoi`

## macOS

Install apps and CLI tools with Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/bootstrap.sh)"
```

Then clone the repo and apply the macOS dotfiles:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles && ~/dotfiles/macos/apply.sh
```

The macOS bootstrap installs `chezmoi` from `macos/Brewfile`.

## Linux

Clone the repo, then run the Linux bootstrap and apply dotfiles:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles
~/dotfiles/linux/bootstrap.sh
~/dotfiles/linux/apply.sh
```

After the first bootstrap installs `just`, Linux setup can also be run from the
repo root with:

```bash
just linux
```

The Linux bootstrap currently supports CachyOS and installs `chezmoi` from
`linux/cachyos/packages.txt`.

## Chezmoi

Use the platform apply wrappers instead of running `chezmoi` directly:

```bash
~/dotfiles/macos/apply.sh
~/dotfiles/linux/apply.sh
```

Both wrappers pass extra arguments through to `chezmoi apply`, so previewing is
available with:

```bash
~/dotfiles/macos/apply.sh --dry-run --verbose
~/dotfiles/linux/apply.sh --dry-run --verbose
```

The old `symlinks.sh` scripts are kept as compatibility wrappers and now call
the matching `apply.sh`.

## Windows

Run this in PowerShell to set up a new PC:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/bootstrap.ps1 | iex
```
