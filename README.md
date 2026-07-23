# dotfiles

Personal setup for macOS, CachyOS, Debian/Ubuntu, and Windows. Platform
bootstraps install applications and tools; chezmoi manages home-directory
configuration on macOS and Linux.

## Dotfiles

After running the bootstrap for the current platform, use `just` from the
repository root to manage the setup:

```bash
just apply
```

Preview changes first:

```bash
just apply --dry-run --verbose
```

Except for the wrapper-specific `--headless` option described below, extra
arguments are passed to `chezmoi apply`. Use `just setup` to rerun the platform
bootstrap and apply everything, and `just --list` to show commands relevant to
the current system.

On a headless machine, persist the headless role and apply the matching
configuration with:

```bash
just apply --headless
```

The headless role keeps the shared zsh, prompt, history, and completion setup
while omitting desktop-only, agent/development-only, and GUI configuration.

## macOS

Bootstrap a new Mac before cloning the repository:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/bootstrap.sh)"
```

After the bootstrap completes, clone the repository and apply the dotfiles with
`just`:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles
cd ~/dotfiles
just apply
```

From an existing checkout, run the complete flow with `just setup`.

Update the Homebrew package manifest with:

```bash
brew bundle dump --file=macos/Brewfile --force
```

Install [Grab2Text](https://grab2text.com) manually because it is unavailable
through Homebrew and the Mac App Store.

## Linux

Linux setup supports CachyOS and Debian/Ubuntu. Clone the repository and run the
distro-detecting bootstrap first, then apply the dotfiles:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles
cd ~/dotfiles
./linux/bootstrap.sh
just apply
```

For a headless Debian/Ubuntu server, Git is the only prerequisite needed to
clone the repo; let the bootstrap install zsh and the remaining shell
environment:

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles
cd ~/dotfiles
./linux/bootstrap.sh --headless
just apply
```

Both distro paths install `just` with their configured packages and set zsh as
the login shell. CachyOS additionally enables applicable services and applies
the KDE configuration. The Debian/Ubuntu bootstrap deliberately owns only the
shell environment and repository command runner; server-role packages and
tooling belong in the separate homelab repo.

From then on, use `just setup` to rerun the complete flow, or
`just setup --headless` on a headless Debian/Ubuntu server.

Optional system configuration:

```bash
just gaming-pc    # Gaming PC configuration
just dualsense    # DualSense UCM workaround
just refind-theme # rEFInd Regular theme
```

Set `REFIND_DIR` before `just refind-theme` if rEFInd is not installed under
one of the common EFI paths.

## Windows

Run this in PowerShell on a new PC:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/vsharha/dotfiles/main/windows/bootstrap.ps1 | iex
```

Update the Windows Package Manager manifest from the repository root with:

```powershell
winget export --output windows/apps.json --accept-source-agreements
```

Windows setup currently restores applications only; it does not apply the
macOS/Linux chezmoi configuration.

## Manual backups

`backups/sponsorblock/config.json` is a manual SponsorBlock settings export.
Import it through the extension UI; no setup command applies it.
