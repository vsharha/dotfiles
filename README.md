# dotfiles

Platform setup scripts install apps and tools. Dotfiles are managed by chezmoi
from two source layers: a shared `home/` directory, which uses templates to
handle per-OS differences (plugin paths, ghostty settings), plus a per-OS
overlay (`macos/home/` or `linux/home/`) for files that only exist on one OS.
`apply.sh` applies both in turn.

Apply dotfiles on any platform:

```bash
./apply.sh
```

Preview changes first:

```bash
./apply.sh --dry-run --verbose
```

Extra arguments are passed through to `chezmoi apply`. With `just`:

```bash
just apply
```

## macOS

Install apps and CLI tools with Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/bootstrap.sh)"
```

Then clone the repo and apply the dotfiles:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles && ~/dotfiles/apply.sh
```

The macOS bootstrap installs `chezmoi` from `macos/Brewfile`.

## Linux

Clone the repo, then run the Linux bootstrap and apply dotfiles:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles
~/dotfiles/linux/bootstrap.sh
~/dotfiles/apply.sh
```

After the first bootstrap installs `just`, the full setup flow (bootstrap +
apply) is available from the repo root with:

```bash
just setup
```

Recipes are OS-aware: `just --list` only shows the ones relevant to the
current OS, and `just bootstrap`/`just setup` run the right platform variant.

The Linux bootstrap currently supports CachyOS. It installs packages (including
`chezmoi`, zsh, and the same zsh plugins used on macOS) from
`linux/cachyos/packages.txt` and `linux/cachyos/aur-packages.txt`, and sets zsh
as the login shell so both systems share the same `.zshrc` and p10k config.

## Windows

Run this in PowerShell to set up a new PC:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/bootstrap.ps1 | iex
```

## Browser

`browser/sponsorblock/config.json` is a manual backup of SponsorBlock settings;
nothing applies it automatically — import it through the extension's UI.
