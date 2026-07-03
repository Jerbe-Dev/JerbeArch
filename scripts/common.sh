#!/usr/bin/env bash
# scripts/common.sh — shared helpers, sourced by every module

log()  { echo -e "\e[1;32m[+]\e[0m $*"; }
warn() { echo -e "\e[1;33m[!]\e[0m $*"; }
die()  { echo -e "\e[1;31m[x]\e[0m $*" >&2; exit 1; }

check_uefi() {
    if [[ ! -d /sys/firmware/efi/efivars ]]; then
        die "Not booted in UEFI mode. This installer only supports UEFI + GRUB."
    fi
    log "UEFI boot confirmed."
}

check_internet() {
    log "Checking internet connectivity..."
    if ! ping -c 2 archlinux.org &>/dev/null; then
        die "No internet connection. Connect first (see scripts/wifi.sh) and re-run."
    fi
    log "Internet OK."
}

set_partition_names() {
    # Populates PART1 (EFI), PART2 (swap), PART3 (root) based on $DISK
    if [[ "$DISK" == *"nvme"* || "$DISK" == *"mmcblk"* ]]; then
        PART1="${DISK}p1"
        PART2="${DISK}p2"
        PART3="${DISK}p3"
    else
        PART1="${DISK}1"
        PART2="${DISK}2"
        PART3="${DISK}3"
    fi
}
