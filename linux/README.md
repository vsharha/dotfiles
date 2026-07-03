# Linux

Shared Linux setup lives here. Distro-specific setup should stay in a
subdirectory such as `cachyos/`.

Run the general bootstrap from the repo root:

```bash
./linux/bootstrap.sh
```

On CachyOS this installs packages from:

- `linux/cachyos/packages.txt` with `pacman`
- `linux/cachyos/aur-packages.txt` with `paru`

It also applies shared KDE keyboard preferences when `kwriteconfig6` is
available. Symlinks are intentionally separate.

Link Linux configs and home files:

```bash
./linux/symlinks.sh
```

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
