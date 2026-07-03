# Linux

Shared Linux setup lives here. Distro-specific setup should stay in a
subdirectory such as `cachyos/`.

Dotfiles are managed by chezmoi from `linux/chezmoi`.

Run the general bootstrap from the repo root:

```bash
./linux/bootstrap.sh
```

After bootstrap installs `just`, the same Linux setup flow is available from the
repo root:

```bash
just linux
```

On CachyOS this installs packages from:

- `linux/cachyos/packages.txt` with `pacman`
- `linux/cachyos/aur-packages.txt` with `paru`

It also applies shared KDE keyboard preferences when `kwriteconfig6` is
available. Chezmoi-managed dotfiles are intentionally separate.

Apply Linux dotfiles:

```bash
./linux/apply.sh
```

Or with `just`:

```bash
just linux-apply
```

Preview changes before applying:

```bash
./linux/apply.sh --dry-run --verbose
```

Or with `just`:

```bash
just linux-dry
```

`linux/symlinks.sh` is deprecated and remains only as a compatibility wrapper
around `linux/apply.sh`.

Optional machine-specific setup:

```bash
./linux/hardware/gaming-pc-amd-7800x3d-rx9070xt.sh
./linux/hardware/dualsense-ucm-fix.sh
```

Optional boot theme setup:

```bash
./linux/boot/refind-theme-regular.sh
```

Set `REFIND_DIR` if rEFInd is not installed under one of the common EFI paths.
