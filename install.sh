#!/usr/bin/env bash
#
# install.sh — JerbeArch main entry point
#
# Usage (from the Arch ISO live environment):
#   pacman -Sy git
#   git clone https://github.com/<your-username>/JerbeArch.git
#   cd JerbeArch
#   chmod +x install.sh
#   ./install.sh
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$ROOT_DIR/config.sh"
source "$ROOT_DIR/scripts/common.sh"
source "$ROOT_DIR/scripts/wifi.sh"
source "$ROOT_DIR/scripts/partition.sh"
source "$ROOT_DIR/scripts/format.sh"
source "$ROOT_DIR/scripts/pacstrap.sh"

main() {
    check_uefi
    connect_wifi
    check_internet

    select_disk
    do_partition
    do_format
    do_mount

    do_pacstrap
    do_fstab

    log "Copying installer into new system for chroot step..."
    mkdir -p /mnt/root/JerbeArch-setup
    cp -r "$ROOT_DIR"/{config.sh,scripts,files} /mnt/root/JerbeArch-setup/

    read -rsp "Set ROOT password: " ROOT_PASS; echo
    read -rsp "Set password for user '${USERNAME}': " USER_PASS; echo

    log "Entering chroot to finish configuration..."
    arch-chroot /mnt /usr/bin/env \
        ROOT_PASS="$ROOT_PASS" \
        USER_PASS="$USER_PASS" \
        bash /root/JerbeArch-setup/scripts/chroot.sh

    unset ROOT_PASS USER_PASS

    source "$ROOT_DIR/scripts/cleanup.sh"
    do_cleanup
}

main
