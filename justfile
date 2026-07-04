default:
    just --list

linux:
    ./linux/bootstrap.sh
    ./linux/apply.sh

linux-bootstrap:
    ./linux/bootstrap.sh

linux-apply *args:
    ./linux/apply.sh {{args}}

linux-kde:
    ./linux/kde.sh

linux-gaming-pc:
    ./linux/hardware/gaming-pc-amd-7800x3d-rx9070xt.sh

linux-dualsense:
    ./linux/hardware/dualsense-ucm-fix.sh

linux-refind-theme:
    ./linux/boot/refind-theme-regular.sh
