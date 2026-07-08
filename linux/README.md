# Linux

Shared Linux setup lives here. Distro-specific setup should stay in a
subdirectory such as `cachyos/`.

Dotfiles are managed by chezmoi from the shared `home/` source at the repo
root — see the top-level README. Apply them with `../apply.sh` or `just apply`.

Run the general bootstrap from the repo root:

```bash
./linux/bootstrap.sh
```

After bootstrap installs `just`, the full setup flow (bootstrap + apply) is
available from the repo root:

```bash
just setup
```

On CachyOS this installs packages from:

- `linux/cachyos/packages.txt` with `pacman`
- `linux/cachyos/aur-packages.txt` with `paru`

The package lists include zsh, powerlevel10k, and the same plugin set used on
macOS (fzf-tab, autosuggestions, syntax highlighting, history substring
search), and the bootstrap sets zsh as the login shell, so the shared `.zshrc`
and `.p10k.zsh` work identically on both systems.

It also applies shared KDE keyboard preferences when `kwriteconfig6` is
available.

Optional machine-specific setup:

```bash
./linux/hardware/gaming-pc-amd-7800x3d-rx9070xt.sh
./linux/hardware/dualsense-ucm-fix.sh
```

The gaming PC script installs `linux/hardware/fastfetch.jsonc` as the
Fastfetch config.

Optional boot theme setup:

```bash
./linux/boot/refind-theme-regular.sh
```

The theme settings live in `linux/boot/refind-theme-regular.conf` (checked in,
copied over the cloned theme). Set `REFIND_DIR` if rEFInd is not installed
under one of the common EFI paths.
