# dotfiles

Personal setup for macOS, CachyOS, and Windows. Platform bootstraps install
applications and tools; chezmoi manages home-directory configuration on macOS
and Linux.

## Dotfiles

Apply the shared dotfiles and the current OS-specific configuration:

```bash
./apply.sh
```

Preview changes first:

```bash
./apply.sh --dry-run --verbose
```

Extra arguments are passed to `chezmoi apply`. Once `just` is installed, use
`just apply` to apply dotfiles, `just setup` to bootstrap and apply everything,
and `just --list` to show commands relevant to the current system.

## macOS

Bootstrap a new Mac before cloning the repository:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vsharha/dotfiles/main/macos/bootstrap.sh)"
```

Then clone the repository and apply dotfiles:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles
~/dotfiles/apply.sh
```

From an existing checkout, run the complete flow with `just setup`.

Update the Homebrew package manifest with:

```bash
brew bundle dump --file=macos/Brewfile --force
```

Install [Grab2Text](https://grab2text.com) manually because it is unavailable
through Homebrew and the Mac App Store.

## Linux

Linux setup currently supports CachyOS. Clone the repository, bootstrap the
system, then apply dotfiles:

```bash
git clone https://github.com/vsharha/dotfiles.git ~/dotfiles
~/dotfiles/linux/bootstrap.sh
~/dotfiles/apply.sh
```

The bootstrap installs the configured packages, sets zsh as the login shell,
enables applicable services, and applies the KDE configuration. After the first
bootstrap installs `just`, the complete flow is available as `just setup`.

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
